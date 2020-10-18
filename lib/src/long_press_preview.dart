import 'dart:async';
import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:long_press_preview/src/long_press_preview_dialog.dart';

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

  OverlayState overlay;
  OverlayEntry oe;

  LongPressPreviewAnimationControllerManager touchAnimationController;
  double childWidgetScale = 1;

  // touch animation threshold Exceeding it will start animation
  static int touchAnimationThreshold = 50;

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

  // 状态重制并销毁
  void _dispose() {
    if (longPressPreviewDialog == null) return;
    oe.remove();
    setState(() {
      longPressPreviewDialog = null;
    });
  }

  void initTouchAnimation() {
    touchAnimationController =
        LongPressPreviewAnimationControllerManager(this, milliseconds: 150, parametricCurve: Curves.linear, screenSize: MediaQuery.of(context).size);
    touchAnimationController.setAnimation(LongPressPreviewAnimationKey.touchAnimation, begin: 1, end: 0.95, callBack: (val) {
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
  void dispose() {
    super.dispose();
    touchAnimationController.dispose();
  }

  Future<void> startTouchAnimation() async {
    await touchAnimationController.controller.forward();
    if (touchIn) touchAnimationController.reverse();
  }

  Future<void> reverseTouchAnimation(Offset globalPosition) async {
    touchIn = false;
    if (touchAnimationController.controller.isAnimating) {
      touchAnimationController.controller.stop();
      _createLongPressPreviewDialog(globalPosition, context);
    } else {
      widget.onTap();
    }
    touchAnimationController.reverse();
  }

  // do noting touch with widget is too short
  Future<void> waitToAnimation() async {
    touchIn = true;
    touchTimer = Timer(Duration(milliseconds: touchAnimationThreshold), () {
      touchTimer.cancel();
      if (touchIn) startTouchAnimation();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
        // 首次聚焦并且手指移动的情况
        onPointerMove: (PointerMoveEvent event) {
          if (longPressPreviewDialog != null) {
            longPressPreviewDialog.updateMovePosition(event);
          }
        },
        child: GestureDetector(
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
            child: Offstage(offstage: longPressPreviewDialog != null, child: Transform.scale(child: widget.child, scale: childWidgetScale))));
  }
}
