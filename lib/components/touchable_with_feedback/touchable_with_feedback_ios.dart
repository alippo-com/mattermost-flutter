
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:mattermost_flutter/types/style_prop.dart'; // Ensure correct path for types

class TouchableWithFeedbackIOS extends StatelessWidget {
  final Widget child;
  final bool cancelTouchOnPanning;
  final String testID;
  final String type;
  final StyleProp? style;

  const TouchableWithFeedbackIOS({
    Key? key,
    required this.child,
    required this.cancelTouchOnPanning,
    required this.testID,
    this.type = 'native',
    this.style,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final panResponder = GestureRecognizerFactoryWithHandlers<PanGestureRecognizer>(
      () => PanGestureRecognizer(),
      (PanGestureRecognizer instance) {
        instance.onUpdate = (DragUpdateDetails details) {
          if (cancelTouchOnPanning && 
              (details.delta.dx >= 5 || details.delta.dy >= 5 || details.primaryDelta! > 5)) {
            // Handle panning event
          }
        };
      },
    );

    switch (type) {
      case 'native':
        return GestureDetector(
          key: Key(testID),
          onPanUpdate: panResponder.recognizer?.onUpdate,
          child: InkWell(
            key: Key(testID),
            onTap: () {},
            child: Container(
              decoration: style?.toBoxDecoration(),
              child: child,
            ),
          ),
        );
      case 'opacity':
        return Opacity(
          key: Key(testID),
          opacity: 0.7,
          child: GestureDetector(
            key: Key(testID),
            onTap: () {},
            child: Container(
              decoration: style?.toBoxDecoration(),
              child: child,
            ),
          ),
        );
      default:
        return GestureDetector(
          key: Key(testID),
          onTap: () {},
          child: Container(
            decoration: style?.toBoxDecoration(),
            child: child,
          ),
        );
    }
  }
}
