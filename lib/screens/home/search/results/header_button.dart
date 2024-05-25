
import 'package:flutter/material.dart';
import 'package:mattermost_flutter/hooks/theme.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/types/typography.dart';

class SelectButton extends StatelessWidget {
  final VoidCallback onPress;
  final bool selected;
  final String text;

  const SelectButton({
    required this.onPress,
    required this.selected,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final theme = useTheme(context);
    final styles = getStyleFromTheme(theme);

    return GestureDetector(
      onTap: onPress,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: selected ? changeOpacity(theme.buttonBg, 0.1) : null,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            text,
            style: selected
                ? styles['selectedText']
                : styles['unselectedText'],
          ),
        ),
      ),
    );
  }

  Map<String, TextStyle> getStyleFromTheme(ThemeData theme) {
    return {
      'selectedText': TextStyle(
        color: theme.buttonBg,
        // Add other typography properties here
      ),
      'unselectedText': TextStyle(
        color: changeOpacity(theme.centerChannelColor, 0.56),
        // Add other typography properties here
      ),
      'text': TextStyle(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        // Add other typography properties here
      ),
    };
  }
}

Color changeOpacity(Color color, double opacity) {
  return color.withOpacity(opacity);
}
