import 'package:flutter/material.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/typography.dart';

class UnavailableIconWrapper extends StatelessWidget {
  final String name;
  final double size;
  final TextStyle? style;
  final bool unavailable;
  final BoxDecoration? errorContainerStyle;

  const UnavailableIconWrapper({
    Key? key,
    required this.name,
    required this.size,
    this.style,
    required this.unavailable,
    this.errorContainerStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = useTheme(context);
    final styles = getStyleSheet(theme);
    final errorIconSize = size / 2;

    return Stack(
      children: [
        Icon(
          Icons.getIconData(name),
          size: size,
          color: style?.color ?? (unavailable ? changeOpacity(theme.buttonColor, 0.32) : null),
        ),
        if (unavailable)
          Positioned(
            right: 0,
            child: Container(
              decoration: errorContainerStyle ?? styles['errorContainer'],
              child: Icon(
                Icons.close,
                size: errorIconSize,
                color: theme.dndIndicator,
              ),
            ),
          ),
      ],
    );
  }

  Map<String, BoxDecoration> getStyleSheet(ThemeData theme) {
    return {
      'errorContainer': BoxDecoration(
        color: theme.centerChannelColor,
        border: Border.all(color: theme.centerChannelColor, width: 0.5),
        borderRadius: BorderRadius.circular(size / 2),
      ),
    };
  }
}
