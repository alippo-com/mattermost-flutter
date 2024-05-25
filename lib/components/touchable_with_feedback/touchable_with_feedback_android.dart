import 'package:flutter/material.dart';
import 'package:mattermost_flutter/types/style_prop.dart'; // Ensure correct path for types

class TouchableWithFeedbackAndroid extends StatelessWidget {
  final Widget child;
  final bool borderlessRipple;
  final double? rippleRadius;
  final String testID;
  final String type;
  final Color underlayColor;
  final StyleProp? style;

  const TouchableWithFeedbackAndroid({
    Key? key,
    required this.child,
    this.borderlessRipple = false,
    this.rippleRadius,
    required this.testID,
    this.type = 'native',
    required this.underlayColor,
    this.style,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case 'native':
        return InkWell(
          key: Key(testID),
          onTap: () {},
          splashColor: underlayColor,
          borderRadius: borderlessRipple ? null : BorderRadius.circular(rippleRadius ?? 0),
          child: Container(
            decoration: style?.toBoxDecoration(),
            child: child,
          ),
        );
      case 'opacity':
        return InkWell(
          key: Key(testID),
          onTap: () {},
          child: Opacity(
            opacity: 0.7,
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
