import 'package:flutter/material.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/typography.dart';

class TutorialSwipeLeft extends StatelessWidget {
  final BoxDecoration? containerStyle;
  final String message;
  final BoxDecoration? style;
  final TextStyle? textStyles;

  const TutorialSwipeLeft({
    Key? key,
    this.containerStyle,
    required this.message,
    this.style,
    this.textStyles,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = useTheme(context);
    final styles = getStyleSheet(theme);

    return IgnorePointer(
      child: Container(
        decoration: containerStyle,
        child: Center(
          child: Container(
            decoration: styles.view,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                HandSwipeLeft(fillColor: theme.centerChannelColor),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                  child: Text(
                    message,
                    style: textStyles?.merge(styles.text) ?? styles.text,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _TutorialSwipeLeftStyles getStyleSheet(ThemeData theme) {
    return _TutorialSwipeLeftStyles(
      view: BoxDecoration(
        color: theme.centerChannelBg,
        borderRadius: BorderRadius.circular(8),
      ),
      text: typography('Heading', 200).copyWith(
        color: theme.centerChannelColor,
      ),
    );
  }
}

class _TutorialSwipeLeftStyles {
  final BoxDecoration view;
  final TextStyle text;

  _TutorialSwipeLeftStyles({
    required this.view,
    required this.text,
  });
}
