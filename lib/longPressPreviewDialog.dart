import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class LongPressPreview extends StatefulWidget {
  LongPressPreview({Key key, Widget this.child, Widget this.content});
  Widget content;
  Widget child;

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return LongPressPreviewState();
  }
}

class LongPressPreviewState extends State<LongPressPreview> {
  LongPressPreviewDialog longPressPreviewDialog;
  OverlayState overlay;
  bool firstApend = true;
  OverlayEntry oe;

  OverlayEntry _createLongPressPreviewDialog() {
    if (longPressPreviewDialog == null) {
      overlay = Overlay.of(context);
      longPressPreviewDialog = LongPressPreviewDialog(child: widget.content, dispose: _dispose);
      oe = OverlayEntry(builder: (BuildContext context) {
        return longPressPreviewDialog;
      });
      overlay.insert(oe);
    }
  }

  void _dispose() {
    firstApend = false;
    oe.remove();
    longPressPreviewDialog = null;
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
        onPointerMove: (PointerMoveEvent event) {
          if (longPressPreviewDialog != null && firstApend) {
            longPressPreviewDialog.updateMovePosition(event);
          }
        },
        onPointerUp: (event) => firstApend = false,
        child: GestureDetector(
            onLongPress: () {
              _createLongPressPreviewDialog();
            },
            onLongPressEnd: (LongPressEndDetails e) {
              if (longPressPreviewDialog != null) {
                longPressPreviewDialog.onLongPressEnd();
              }
            },
            child: widget.child));
  }
}

class LongPressPreviewDialog extends StatefulWidget {
  LongPressPreviewDialog({Key key, this.elevation, this.child, this.longPressStartDetails, this.dispose}) : super(key: key);

  /// If null then [DialogTheme.elevation] is used, and if that's null then the
  /// dialog's elevation is 24.0.
  /// {@endtemplate}
  /// {@macro flutter.material.material.elevation}
  final double elevation;

  /// The widget below this widget in the tree.
  ///
  /// {@macro flutter.widgets.child}
  final Widget child;

  LongPressPreviewDialogState state;

  LongPressStartDetails longPressStartDetails;

  Function dispose;

  void updateMovePosition(PointerMoveEvent event) {
    state.onDragUpdate(event.delta);
  }

  void onLongPressEnd() {
    state.onDragEnd();
  }

  @override
  State<StatefulWidget> createState() {
    return state = LongPressPreviewDialogState();
  }
}

class LongPressPreviewDialogState extends State<LongPressPreviewDialog> with SingleTickerProviderStateMixin {
  static const double _defaultElevation = 24.0;
  static const RoundedRectangleBorder _defaultDialogShape = RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4.0)));
  // dialog axis Y move
  double _moveY = 0.0;
  double _moveX = 0.0;

  Animation<double> moveYAnimation;
  Animation<double> moveXAnimation;

  Animation<double> resetXAnimation;
  Animation<double> resetYAnimation;
  Animation<double> scaleAnimation;

  Animation<double> curve;

  double _negativeCount = 0;

  double _scale = 1;

  AnimationController animationController;

  void onDragStart(DragDownDetails details) {
    print(details);
  }

  void onLongPressMoveUpdate(e) {
    print('onLongPressMoveUpdate$e');
  }

  void onDragUpdate(Offset delta) {
    if (_moveY + delta.dy >= 0 && _negativeCount >= 0) {
      setState(() {
        _moveY += delta.dy;
      });
    } else {
      setState(() {
        _moveY = 0;
      });
    }
    setState(() {
      _moveX += delta.dx / 4;
    });
    _negativeCount += delta.dy;
    print('_negative_count  $_negativeCount');
    computedScale();
  }

  void onDragEnd() {
    if (_moveY > 300) return widget.dispose();
    resetXAnimation = Tween<double>(begin: _moveX, end: 0).animate(curve)
      ..addListener(() {
        setState(() {
          _moveX = resetXAnimation.value;
        });
      });
    resetYAnimation = Tween<double>(begin: _moveY, end: 0).animate(curve)
      ..addListener(() {
        setState(() {
          _moveY = resetYAnimation.value;
        });
      });
    scaleAnimation = Tween<double>(begin: _scale, end: 1).animate(curve)
      ..addListener(() {
        setState(() {
          _scale = scaleAnimation.value;
        });
      });
    if (animationController?.isCompleted) {
      animationController.reset();
    }
    animationController.forward();
    _negativeCount = 0;
  }

  computedScale() {
    double _ = _negativeCount / MediaQuery.of(context).size.height;
    if (_negativeCount > 0) {
      _scale = 1 - (_ / 2);
    } else {
      _scale = 1 + (_ / 3);
    }
  }

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 200));
    curve = CurvedAnimation(parent: animationController, curve: Curves.easeOut);
  }

  @override
  Widget build(BuildContext context) {
    final DialogTheme dialogTheme = DialogTheme.of(context);
    return Listener(
        onPointerMove: (PointerMoveEvent e) {
          print('123213321');
        },
        child: GestureDetector(
            onTap: () => widget.dispose(),
            behavior: HitTestBehavior.translucent,
            onPanDown: (DragDownDetails details) => onDragStart(details),
            onPanUpdate: (DragUpdateDetails details) => onDragUpdate(details.delta),
            onPanEnd: (DragEndDetails details) => onDragEnd(),
            child: ClipRect(
                child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                        color: Colors.white.withOpacity(0),
                        child: Center(
                            child: GestureDetector(
                                onTap: () => print('qwdqwdqw'),
                                child: ConstrainedBox(
                                    constraints: const BoxConstraints(minWidth: 280.0),
                                    child: Material(
                                        elevation: widget.elevation ?? dialogTheme.elevation ?? _defaultElevation,
                                        shape: _defaultDialogShape,
                                        child: Transform.translate(
                                            offset: Offset(_moveX, _moveY),
                                            child: Transform.scale(
                                                scale: _scale,
                                                child: Container(height: 200, width: 200, child: Text(_moveX.toString()), color: Colors.white))))))))))));
  }
}

// LongPressPreviewDialog showLongPressPreviewDialog<T>({@required BuildContext context, Widget content}) {
//   LongPressPreviewDialog longPressPreviewDialog = LongPressPreviewDialog(
//     child: content,
//   );
//   showGeneralDialog(
//     barrierDismissible: true,
//     barrierLabel: '',
//     barrierColor: Colors.black38,
//     transitionDuration: Duration(milliseconds: 200),
//     pageBuilder: (ctx, anim1, anim2) => longPressPreviewDialog,
//     transitionBuilder: (ctx, anim1, anim2, child) => BackdropFilter(
//       filter: ImageFilter.blur(sigmaX: 4 * anim1.value, sigmaY: 4 * anim1.value),
//       child: FadeTransition(
//         child: child,
//         opacity: anim1,
//       ),
//     ),
//     context: context,
//   );
//   return longPressPreviewDialog;
// }
