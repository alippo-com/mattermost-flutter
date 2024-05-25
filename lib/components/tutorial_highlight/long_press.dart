import 'package:flutter/material.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/typography.dart';
import 'package:mattermost_flutter/components/tutorial_highlight/long_press_illustration.dart';

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
    final styles = _getStyleSheet(theme);

    return IgnorePointer(
      child: Container(
        decoration: styles.container.merge(containerStyle),
        child: Container(
          decoration: styles.view.merge(style),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              LongPressIllustration(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Text(
                  message,
                  style: styles.text.merge(textStyles),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _StyleSheet _getStyleSheet(ThemeData theme) {
    return _StyleSheet(
      container: BoxDecoration(
        position: DecorationPosition.background,
        color: Colors.transparent,
      ),
      view: BoxDecoration(
        color: theme.centerChannelBg,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 8,
          ),
        ],
      ),
      text: TextStyle(
        fontSize: typography('Heading', 200),
        color: theme.centerChannelColor,
        marginTop: 8,
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _StyleSheet {
  final BoxDecoration container;
  final BoxDecoration view;
  final TextStyle text;

  _StyleSheet({
    required this.container,
    required this.view,
    required this.text,
  });
}
