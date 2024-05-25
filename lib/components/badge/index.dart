
// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:mattermost_flutter/types/theme.dart';

class Badge extends StatefulWidget {
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? color;
  final TextStyle? style;
  final String? testID;
  final String type;
  final int value;
  final bool visible;

  const Badge({
    Key? key,
    this.backgroundColor,
    this.borderColor,
    this.color,
    this.style,
    this.testID,
    this.type = 'Normal',
    required this.value,
    this.visible = true,
  }) : super(key: key);

  @override
  _BadgeState createState() => _BadgeState();
}

class _BadgeState extends State<Badge> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  bool _rendered = false;

  @override
  void initState() {
    super.initState();
    _rendered = widget.visible;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _opacity = Tween<double>(begin: widget.visible ? 1 : 0).animate(_controller);

    if (widget.visible) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(Badge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.visible) {
      setState(() {
        _rendered = true;
      });
      _controller.forward();
    } else {
      _controller.reverse().then((_) {
        setState(() {
          _rendered = false;
        });
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.visible && !_rendered) {
      return SizedBox.shrink();
    }

    final theme = useTheme(context);
    final backgroundColor = widget.backgroundColor ?? theme.mentionBg;
    final textColor = widget.color ?? theme.mentionColor;
    double lineHeight = Theme.of(context).platform == TargetPlatform.android ? 21 : 16.5;
    double fontSize = 12;
    double size = widget.value < 0 ? 12 : 22;
    double minWidth = widget.value < 0 ? size : 26;
    Map<String, double> additionalStyle = {};

    if (widget.type == 'Small') {
      size = widget.value < 0 ? 12 : 20;
      lineHeight = Theme.of(context).platform == TargetPlatform.android ? 19 : 15;
      fontSize = 11;
      minWidth = widget.value < 0 ? size : 24;
    }

    final borderRadius = size / 2;
    String badge = widget.value.toString();
    if (widget.value < 0) {
      badge = '';
      additionalStyle = {'paddingHorizontal': 0};
    } else if (widget.value < 99) {
      badge = widget.value.toString();
      additionalStyle = {'paddingHorizontal': 5};
    } else {
      badge = '99+';
      additionalStyle = {'paddingLeft': 4, 'paddingRight': 3};
    }

    return FadeTransition(
      opacity: _opacity,
      child: Transform.scale(
        scale: _opacity.value,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: additionalStyle['paddingHorizontal'] ?? 4),
          decoration: BoxDecoration(
            color: backgroundColor,
            border: Border.all(color: widget.borderColor ?? Colors.transparent),
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          alignment: Alignment.center,
          height: size,
          constraints: BoxConstraints(minWidth: minWidth),
          child: Text(
            badge,
            style: widget.style?.copyWith(
              color: textColor,
              fontSize: fontSize,
              height: lineHeight / fontSize,
            ) ?? TextStyle(
              color: textColor,
              fontSize: fontSize,
              height: lineHeight / fontSize,
            ),
            maxLines: 1,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
