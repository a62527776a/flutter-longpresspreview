import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:long_press_preview/src/long_press_preview_dialog.dart';

class LongPressPreview extends StatefulWidget {
  LongPressPreview(
      {Key key,
      this.child,
      this.onDragToTop,
      this.content,
      this.onContentTap,
      this.onFingerCallBack,
      this.onCreateDialog,
      this.dialogSize = const Size(300, 300)})
      : super(key: key);
  Widget content;
  Widget child;
  Function onContentTap;
  Function onCreateDialog;
  Function onDragToTop;
  Function(LongPressPreviewFingerEvent, Function) onFingerCallBack;

  final Size dialogSize;

  @override
  State<LongPressPreview> createState() => LongPressPreviewState();
}

class LongPressPreviewState extends State<LongPressPreview> {
  LongPressPreviewState();

  // 长按出弹窗
  LongPressPreviewDialog longPressPreviewDialog;

  OverlayState overlay;
  OverlayEntry oe;

  // 创建一个弹窗
  void _createLongPressPreviewDialog(LongPressStartDetails e, BuildContext context) {
    if (widget.onFingerCallBack != null) widget.onFingerCallBack(LongPressPreviewFingerEvent.long_press_start, () => {});
    final Size screenSize = MediaQuery.of(context).size;
    final RenderBox childWidgetContext = context.findRenderObject() as RenderBox;
    if (longPressPreviewDialog == null) {
      overlay = Overlay.of(context);
      setState(() {
        longPressPreviewDialog = LongPressPreviewDialog(
            screenSize: screenSize,
            dispose: _dispose,
            longPressStartDetails: e,
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
            onLongPressStart: (LongPressStartDetails e) {
              _createLongPressPreviewDialog(e, context);
            },
            onLongPressEnd: (LongPressEndDetails e) {
              if (longPressPreviewDialog != null) {
                longPressPreviewDialog.onLongPressEnd(e.velocity);
              }
            },
            child: Offstage(offstage: longPressPreviewDialog != null, child: widget.child)));
  }
}
