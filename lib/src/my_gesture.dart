import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class LongPressPreviewGesture extends GestureDetector {
  LongPressPreviewGesture({onTapDown, onTapUp, onLongPressStart, onLongPressEnd, child})
      : super(onTapDown: onTapDown, onTapUp: onTapUp, onLongPressStart: onLongPressStart, onLongPressEnd: onLongPressEnd, child: child);
  @override
  Widget build(BuildContext context) {
    final Map<Type, GestureRecognizerFactory> gestures = <Type, GestureRecognizerFactory>{};

    if (onTapDown != null ||
        onTapUp != null ||
        onTap != null ||
        onTapCancel != null ||
        onSecondaryTap != null ||
        onSecondaryTapDown != null ||
        onSecondaryTapUp != null ||
        onSecondaryTapCancel != null ||
        onTertiaryTapDown != null ||
        onTertiaryTapUp != null ||
        onTertiaryTapCancel != null) {
      gestures[TapGestureRecognizer] = GestureRecognizerFactoryWithHandlers<TapGestureRecognizer>(
        () => TapGestureRecognizer(debugOwner: this),
        (TapGestureRecognizer instance) {
          instance
            ..onTapDown = onTapDown
            ..onTapUp = onTapUp
            ..onTap = onTap
            ..onTapCancel = onTapCancel
            ..onSecondaryTap = onSecondaryTap
            ..onSecondaryTapDown = onSecondaryTapDown
            ..onSecondaryTapUp = onSecondaryTapUp
            ..onSecondaryTapCancel = onSecondaryTapCancel
            ..onTertiaryTapDown = onTertiaryTapDown
            ..onTertiaryTapUp = onTertiaryTapUp
            ..onTertiaryTapCancel = onTertiaryTapCancel;
        },
      );
      if (onLongPress != null ||
          onLongPressUp != null ||
          onLongPressStart != null ||
          onLongPressMoveUpdate != null ||
          onLongPressEnd != null ||
          onSecondaryLongPress != null ||
          onSecondaryLongPressUp != null ||
          onSecondaryLongPressStart != null ||
          onSecondaryLongPressMoveUpdate != null ||
          onSecondaryLongPressEnd != null) {
        gestures[LongPressGestureRecognizer] = GestureRecognizerFactoryWithHandlers<LongPressGestureRecognizer>(
          () => LongPressGestureRecognizer(debugOwner: this, duration: Duration(milliseconds: 250)),
          (LongPressGestureRecognizer instance) {
            instance
              ..onLongPress = onLongPress
              ..onLongPressStart = onLongPressStart
              ..onLongPressMoveUpdate = onLongPressMoveUpdate
              ..onLongPressEnd = onLongPressEnd
              ..onLongPressUp = onLongPressUp
              ..onSecondaryLongPress = onSecondaryLongPress
              ..onSecondaryLongPressStart = onSecondaryLongPressStart
              ..onSecondaryLongPressMoveUpdate = onSecondaryLongPressMoveUpdate
              ..onSecondaryLongPressEnd = onSecondaryLongPressEnd
              ..onSecondaryLongPressUp = onSecondaryLongPressUp;
          },
        );
      }
      return RawGestureDetector(
        gestures: gestures,
        behavior: behavior,
        excludeFromSemantics: excludeFromSemantics,
        child: child,
      );
    }
  }
}
