
import 'package:flutter/material.dart';

class TouchableWithFeedback extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color backgroundColor;
  final double borderRadius;
  final double elevation;
  final EdgeInsetsGeometry padding;

  const TouchableWithFeedback({
    Key? key,
    required this.child,
    this.onTap,
    this.backgroundColor = Colors.transparent,
    this.borderRadius = 0.0,
    this.elevation = 0.0,
    this.padding = const EdgeInsets.all(0),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      elevation: elevation,
      borderRadius: BorderRadius.circular(borderRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}
