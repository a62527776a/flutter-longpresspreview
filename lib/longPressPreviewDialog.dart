import 'dart:math';
import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class LongPressPreviewFingerMoveCountManager {
  LongPressPreviewFingerMoveCountManager();

  // Sum of finger movement on Y axis
  double _moveCountOnYaxis = 0;
  // childWidget longPressStart Event's GlobalPosition Y-axis
  double _fingerOnChildWidgetLongPressStartYaxis = 0;

  double get fingerOnChildWidgetLongPressStartYaxis => _fingerOnChildWidgetLongPressStartYaxis;
  double get moveCountOnYaxis => _moveCountOnYaxis;

  void moveOnY(double y) {
    _moveCountOnYaxis += y;
  }

  void resetYAxisMovementCount() {
    _moveCountOnYaxis = 0;
  }

  void setLongPressStartY(double y) {
    _fingerOnChildWidgetLongPressStartYaxis = y;
  }
}

class LongPressPreviewDialogPrototypeManager {
  LongPressPreviewDialogPrototypeManager();

  // dialog X-axis orientation
  double _x = 0;
  // dialog Y-axis orientation
  double _y = 0;

  // dialog size
  double _height = 0;
  double _width = 0;

  // dialog scale
  double _scale = 1;

  // dialog oMask blur prototype
  double _maskBlur = 0;
  double get maskMaxBlur => 10;
  double get maskMinBlur => 0;

  Offset get position => Offset(_x, _y);

  Size get size => Size(_width, _height);
  Size get maxSize => const Size(300, 300);
  double get scale => _scale;
  double get maskBlur => _maskBlur;

  // Maximum movable y-axis
  double get yAxisMaxMoveable => 0;

  void xMoveBy(double x) {
    _x += x;
  }

  void yMoveBy(double y) {
    _y += y;
  }

  void xReset() {
    _x = 0;
  }

  void yReset() {
    _y = 0;
  }

  void xMoveOn(double x) {
    _x = x;
  }

  void yMoveOn(double y) {
    _y = y;
  }

  void setSize({double height, double width}) {
    if (height.runtimeType == double) {
      _height = height;
    }
    if (width.runtimeType == double) {
      _width = width;
    }
  }

  setPosition(Offset offset) {
    _x = offset.dx;
    _y = offset.dy;
  }

  void zoom(double scale) {
    print(scale);
    _scale = scale;
  }

  void setBlur(double blur) {
    _maskBlur = blur;
  }
}

enum LongPressPreviewAnimationKey { blurAnimation, sizeAnimation, positionAnimation, scaleAnimation, childWidgetTransferDialogWidgetAnimation }

class LongPressPreviewAnimationControllerManager {
  LongPressPreviewAnimationControllerManager(TickerProvider that, {this.milliseconds, this.parametricCurve, this.screenSize}) {
    init(that);
  }

  int milliseconds;
  Curve parametricCurve;
  final Size screenSize;

  Animation<double> get curve => _curve;
  AnimationController get controller => _controller;

  AnimationController _controller;
  Animation<double> _curve;

  Map<LongPressPreviewAnimationKey, Animation<dynamic>> animations = <LongPressPreviewAnimationKey, Animation<dynamic>>{};

  void init(TickerProvider that) {
    _controller = AnimationController(vsync: that, duration: Duration(milliseconds: milliseconds));
    _curve = CurvedAnimation(parent: _controller, curve: parametricCurve);
  }

  Animation<double> buildCurve(Curve curve) {
    return CurvedAnimation(parent: _controller, curve: curve);
  }

  void forward() {
    if (_controller?.isCompleted ?? false) _controller.reset();
    _controller.forward();
  }

  Future<void> reverse() async {
    await _controller.reverse();
  }

  void dispose() {
    _controller.dispose();
  }

  void setAnimation(LongPressPreviewAnimationKey key,
      {dynamic begin, dynamic end, Function callBack, Animation<double> otherCurve, Offset pixelsPerSecond}) async {
    animations[key] = Tween<dynamic>(begin: begin, end: end).animate(otherCurve ?? curve)
      ..addListener(() {
        callBack(animations[key].value);
      });
  }
}

class LongPressPreviewDialog extends StatefulWidget {
  LongPressPreviewDialog(
      {Key key,
      this.elevation,
      this.child,
      this.screenSize,
      this.longPressStartDetails,
      this.content,
      this.dispose,
      this.childWidgetSize,
      this.childWidgetPosition})
      : super(key: key);

  final double elevation;

  final Widget child;
  final Widget content;

  final Size screenSize;

  LongPressPreviewDialogState state;

  // 暂存首次长按的信息
  LongPressStartDetails longPressStartDetails;

  Size childWidgetSize;
  Offset childWidgetPosition;

  Function dispose;

  void updateMovePosition(PointerMoveEvent event) {
    state ??= LongPressPreviewDialogState();
    state.onDragUpdate(event.delta);
  }

  void onLongPressEnd(Velocity velocity) {
    state.onDragEnd(velocity);
  }

  @override
  State<StatefulWidget> createState() {
    state ??= LongPressPreviewDialogState();
    return state;
  }
}

class LongPressPreviewDialogState extends State<LongPressPreviewDialog> with TickerProviderStateMixin {
  bool dialogTransferFlug = false;

  double screenHeight;
  double screenWidth;

  int outInAnimationDuration = 200;

  Animation<double> childWidgetMoveXDialogAnimation;
  Animation<double> childWidgetMoveYDialogAnimation;

  LongPressPreviewFingerMoveCountManager fingerMoveCountManager = LongPressPreviewFingerMoveCountManager();
  LongPressPreviewDialogPrototypeManager dialogPrototypeManager = LongPressPreviewDialogPrototypeManager();

  LongPressPreviewAnimationControllerManager outInAnimationControllerManager;
  LongPressPreviewAnimationControllerManager resetPositionAnimationControllerManager;

  bool get hasOverflowCloseThreshold =>
      dialogPrototypeManager.position.dy > 120 ||
      ((dialogPrototypeManager.position.dy + fingerMoveCountManager.fingerOnChildWidgetLongPressStartYaxis) >= (screenHeight - 20));

  void onDragStart(DragDownDetails details) {
    fingerMoveCountManager.setLongPressStartY(details.globalPosition.dy);
  }

  void onDragUpdate(Offset delta) {
    if (outInAnimationControllerManager?.controller?.isAnimating ?? false) return;
    if (dialogPrototypeManager.position.dy + delta.dy >= 0 && fingerMoveCountManager.moveCountOnYaxis >= 0) {
      dialogPrototypeManager.yMoveBy(delta.dy);
    } else {
      double scale = -fingerMoveCountManager.moveCountOnYaxis / (screenHeight / 8);
      dialogPrototypeManager.yMoveBy(delta.dy * (max(1 - scale, 0.05)));
    }
    setState(() {
      dialogPrototypeManager.xMoveBy(delta.dx / 4);
    });
    fingerMoveCountManager.moveOnY(delta.dy);
    computedScale();
  }

  Future<void> onDispose() async {
    setState(() {
      dialogTransferFlug = !dialogTransferFlug;
    });
    setChildWidgetMoveDialogAnimation(reverse: true);
    await outInAnimationControllerManager.reverse();
    fingerMoveCountManager.setLongPressStartY(0);
    widget.dispose();
  }

  // dialog move back origin Offset(0, 0)
  // resume scale 1
  void resetAnimation(Velocity velocity) {
    // reset dialog position to origin point animation
    resetPositionAnimationControllerManager.setAnimation(LongPressPreviewAnimationKey.positionAnimation,
        begin: dialogPrototypeManager.position,
        end: const Offset(0, 0),
        pixelsPerSecond: velocity.pixelsPerSecond,
        callBack: (Offset value) => setState(() {
              dialogPrototypeManager.setPosition(value);
            }));
    // reset dialog scale to 1 animation
    resetPositionAnimationControllerManager.setAnimation(LongPressPreviewAnimationKey.scaleAnimation,
        begin: dialogPrototypeManager.scale * 100,
        end: (1.0 * 100),
        callBack: (double value) => setState(() {
              dialogPrototypeManager.zoom(value / 100);
            }));

    resetPositionAnimationControllerManager.forward();
  }

  // fingers off screen
  Future<void> onDragEnd(Velocity velocity) async {
    print(velocity);
    if (hasOverflowCloseThreshold) return onDispose();
    resetAnimation(velocity);
    fingerMoveCountManager.resetYAxisMovementCount();
  }

  void computedScale() {
    final double _ = fingerMoveCountManager.moveCountOnYaxis / MediaQuery.of(context).size.height;
    if (fingerMoveCountManager.moveCountOnYaxis > 0) {
      dialogPrototypeManager.zoom(1 - (_ / 2));
    } else {
      dialogPrototypeManager.zoom(1 + (_ / 3));
    }
  }

  void setChildWidgetMoveDialogAnimation({bool reverse = false}) {
    Offset beginOffset = Offset(widget.childWidgetPosition.dx - screenWidth / 2 + widget.childWidgetSize.width / 2,
        widget.childWidgetPosition.dy - screenHeight / 2 + widget.childWidgetSize.height / 2);
    // childWidget transfer dialog animation need more beautiful curves 😊
    final Animation<double> childWidgetTransferDialogAnimationCurve = outInAnimationControllerManager.buildCurve(Curves.easeOutBack);
    Offset endOffset = reverse ? Offset(dialogPrototypeManager.position.dx, dialogPrototypeManager.position.dy) : const Offset(0, 0);
    outInAnimationControllerManager.setAnimation(LongPressPreviewAnimationKey.childWidgetTransferDialogWidgetAnimation,
        begin: beginOffset,
        end: endOffset,
        otherCurve: childWidgetTransferDialogAnimationCurve,
        callBack: (Offset value) => setState(() {
              dialogPrototypeManager.setPosition(value);
            }));
    if (reverse) {
      outInAnimationControllerManager.setAnimation(LongPressPreviewAnimationKey.scaleAnimation,
          begin: 100.0,
          end: dialogPrototypeManager.scale * 100,
          callBack: (double value) => setState(() {
                dialogPrototypeManager.zoom(value / 100);
              }));
    }
  }

  void dialogInScreenAnimation() {
    setChildWidgetMoveDialogAnimation();
    outInAnimationControllerManager.forward();
    setState(() {
      dialogTransferFlug = !dialogTransferFlug;
    });
  }

  // dialog OutIn animation
  void initOutInAnimation() {
    const int outInAnimationDuration = 200;
    outInAnimationControllerManager =
        LongPressPreviewAnimationControllerManager(this, milliseconds: outInAnimationDuration, parametricCurve: Curves.easeIn, screenSize: widget.screenSize);
    // set mask blur animation
    outInAnimationControllerManager.setAnimation(LongPressPreviewAnimationKey.blurAnimation,
        begin: dialogPrototypeManager.maskBlur,
        end: dialogPrototypeManager.maskMaxBlur,
        callBack: (double value) => setState(() {
              dialogPrototypeManager.setBlur(value);
            }));
    outInAnimationControllerManager.setAnimation(LongPressPreviewAnimationKey.sizeAnimation,
        begin: Size(widget.childWidgetSize.width, widget.childWidgetSize.height),
        end: dialogPrototypeManager.maxSize,
        callBack: (Size size) => setState(() {
              dialogPrototypeManager.setSize(height: size.height, width: size.width);
            }));
  }

  void initResetDialogPositionAnimation() {
    const int resetOffsetAnimationDuration = 200;
    resetPositionAnimationControllerManager = LongPressPreviewAnimationControllerManager(this,
        milliseconds: resetOffsetAnimationDuration, parametricCurve: Curves.easeIn, screenSize: widget.screenSize);
  }

  @override
  void initState() {
    super.initState();
    initOutInAnimation();
    initResetDialogPositionAnimation();
    fingerMoveCountManager.setLongPressStartY(widget.longPressStartDetails.globalPosition.dy);
    WidgetsBinding.instance.addPostFrameCallback((Duration callback) {
      dialogInScreenAnimation();
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    screenHeight = screenSize.height;
    screenWidth = screenSize.width;
    return Listener(
        child: GestureDetector(
            onTap: () => onDispose(),
            behavior: HitTestBehavior.translucent,
            onPanDown: (DragDownDetails details) => onDragStart(details),
            onPanUpdate: (DragUpdateDetails details) => onDragUpdate(details.delta),
            onPanEnd: (DragEndDetails details) => onDragEnd(details.velocity),
            child: ClipRect(
                child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: dialogPrototypeManager.maskBlur, sigmaY: dialogPrototypeManager.maskBlur),
                    child: Container(
                        color: Colors.transparent,
                        child: Center(
                            child: GestureDetector(
                                child: ConstrainedBox(
                                    constraints: BoxConstraints(maxWidth: dialogPrototypeManager.size.width, maxHeight: dialogPrototypeManager.size.height),
                                    child: Transform.translate(
                                        offset: dialogPrototypeManager.position,
                                        child: Transform.scale(
                                            scale: dialogPrototypeManager.scale,
                                            child: AnimatedSwitcher(
                                                transitionBuilder: (Widget child, Animation<double> animation) {
                                                  return FadeTransition(opacity: animation, child: child);
                                                },
                                                duration: Duration(milliseconds: outInAnimationDuration),
                                                child: dialogTransferFlug
                                                    ? Container(key: ValueKey<bool>(dialogTransferFlug), child: widget.content)
                                                    : Container(key: ValueKey<bool>(dialogTransferFlug), child: widget.child))))))))))));
  }
}
