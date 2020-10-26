import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:long_press_preview/src/config.dart';
import 'package:long_press_preview/src/long_press_preview_dialog.dart';
import 'package:long_press_preview/src/my_gesture.dart';

enum TouchAnimationStatus { none, forward, reverse }

class LongPressPreview extends StatefulWidget {
  LongPressPreview({Key key, this.child, this.content, this.onTap, this.onFingerCallBack, this.dialogSize = const Size(300, 300)}) : super(key: key);
  Widget content;
  Widget child;
  Function(LongPressPreviewFingerEvent, Function) onFingerCallBack;

  Function onTap;

  final Size dialogSize;

  @override
  State<LongPressPreview> createState() => LongPressPreviewState();
}

class LongPressPreviewState extends State<LongPressPreview> with TickerProviderStateMixin {
  LongPressPreviewState();

  // 长按出弹窗
  LongPressPreviewDialog longPressPreviewDialog;

  bool inAnimation = false;

  OverlayState overlay;
  OverlayEntry oe;

  LongPressPreviewAnimationControllerManager touchAnimationController;
  TouchAnimationStatus touchAnimationStatus = TouchAnimationStatus.none;
  double childWidgetScale = 1;

  int touchDownTime = 0;
  int touchCancelTime = 0;

  Timer touchTimer;

  // Whether to touch the child widget
  bool touchIn = false;

  // 创建一个弹窗
  void _createLongPressPreviewDialog(Offset globalPosition, BuildContext context) {
    if (widget.onFingerCallBack != null) widget.onFingerCallBack(LongPressPreviewFingerEvent.long_press_start, () => {});
    final Size screenSize = MediaQuery.of(context).size;
    final RenderBox childWidgetContext = context.findRenderObject() as RenderBox;
    if (longPressPreviewDialog == null) {
      overlay = Overlay.of(context);
      setState(() {
        longPressPreviewDialog = LongPressPreviewDialog(
            screenSize: screenSize,
            dispose: _dispose,
            globalPosition: globalPosition,
            dialogAnimationWaitForwardCallBack: dialogAnimationWaitForwardCallBack,
            content: widget.content,
            onFingerCallBack: widget.onFingerCallBack,
            dialogSize: widget.dialogSize,
            childWidgetSize: childWidgetContext.size,
            childWidgetPosition: childWidgetContext.localToGlobal(Offset.zero),
            child: widget.child);
      });
      oe = OverlayEntry(builder: (BuildContext context) {
        return longPressPreviewDialog;
      });
      overlay.insert(oe);
    }
  }

  Future<bool> onWillPop() async {
    if (longPressPreviewDialog != null) {
      longPressPreviewDialog.state.onDispose();
      return false;
    }
    return true;
  }

  // 状态重制并销毁
  void _dispose() {
    if (longPressPreviewDialog == null) return;
    oe.remove();
    setState(() {
      longPressPreviewDialog = null;
    });
  }

  void initTouchAnimation() {
    touchAnimationController = LongPressPreviewAnimationControllerManager(this,
        milliseconds: LongPressPreviewConf.touchAnimationDuration,
        parametricCurve: LongPressPreviewConf.touchAnimationCurves,
        screenSize: MediaQuery.of(context).size);
    touchAnimationController.setAnimation(LongPressPreviewAnimationKey.touchAnimation, begin: 1, end: LongPressPreviewConf.touchScaleMin, callBack: (val) {
      setState(() {
        childWidgetScale = val.toDouble();
      });
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((Duration callback) {
      initTouchAnimation();
    });
  }

  @override
  void dialogAnimationWaitForwardCallBack() {
    inAnimation = false;
  }

  @override
  void dispose() {
    super.dispose();
    touchAnimationController.dispose();
  }

  Future<void> startTouchAnimation() async {
    inAnimation = true;
    touchAnimationStatus = TouchAnimationStatus.forward;
    await touchAnimationController.controller.forward();
    if (touchIn) {
      HapticFeedback.mediumImpact();
      touchAnimationStatus = TouchAnimationStatus.reverse;
      await touchAnimationController.reverse();
    }
    touchAnimationStatus = TouchAnimationStatus.none;
  }

  Future<void> reverseTouchAnimation(Offset globalPosition) async {
    touchIn = false;
    if (touchAnimationStatus == TouchAnimationStatus.reverse) {
      touchAnimationController?.controller?.stop();
      touchAnimationStatus = TouchAnimationStatus.none;
      _createLongPressPreviewDialog(globalPosition, context);
    } else {
      widget.onTap();
    }
    touchAnimationController.reverse();
  }

  // do noting touch with widget is too short
  Future<void> waitToAnimation() async {
    touchIn = true;
    touchTimer = Timer(Duration(milliseconds: LongPressPreviewConf.touchAnimationThreshold), () {
      touchTimer.cancel();
      if (touchIn) startTouchAnimation();
    });
  }

  Widget androidWillPopScope(Widget child) {
    return Platform.isAndroid ? WillPopScope(child: child, onWillPop: onWillPop) : child;
  }

  @override
  Widget build(BuildContext context) {
    return androidWillPopScope(Listener(
        // 首次聚焦并且手指移动的情况
        onPointerMove: (PointerMoveEvent event) {
          if (longPressPreviewDialog != null) {
            longPressPreviewDialog.updateMovePosition(event);
          }
        },
        child: LongPressPreviewGesture(
            onTapDown: (e) {
              waitToAnimation();
            },
            onTapUp: (TapUpDetails e) {
              reverseTouchAnimation(e.globalPosition);
            },
            onLongPressStart: (LongPressStartDetails e) {
              _createLongPressPreviewDialog(e.globalPosition, context);
            },
            onLongPressEnd: (LongPressEndDetails e) {
              if (longPressPreviewDialog != null) {
                longPressPreviewDialog.onLongPressEnd(e.velocity);
              }
            },
            child: Offstage(offstage: longPressPreviewDialog != null, child: Transform.scale(child: widget.child, scale: childWidgetScale)))));
  }
}
