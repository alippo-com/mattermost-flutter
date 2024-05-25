
import 'package:flutter/material.dart';
import 'package:mattermost_flutter/components/animated_numbers.dart';
import 'package:mattermost_flutter/components/emoji.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/typography.dart';

class Reaction extends StatelessWidget {
  final int count;
  final String emojiName;
  final bool highlight;
  final void Function(String) onPress;

  Reaction({
    required this.count,
    required this.emojiName,
    required this.highlight,
    required this.onPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = useTheme(context);
    final styles = getStyleSheet(theme);

    void handlePress() {
      onPress(emojiName);
    }

    return GestureDetector(
      onTap: handlePress,
      child: Container(
        decoration: BoxDecoration(
          color: highlight
              ? changeOpacity(theme.buttonBg, 0.08)
              : theme.centerChannelBg,
          borderRadius: BorderRadius.circular(4),
        ),
        margin: EdgeInsets.only(right: 12),
        height: 32,
        minWidth: 50,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: EdgeInsets.symmetric(horizontal: 5),
              child: Emoji(
                emojiName: emojiName,
                size: 20,
                textStyle: TextStyle(color: Colors.black),
                testID: 'reaction.emoji.$emojiName',
              ),
            ),
            Container(
              margin: EdgeInsets.only(right: 5),
              child: AnimatedNumbers(
                fontStyle: TextStyle(
                  color: highlight
                      ? theme.buttonBg
                      : changeOpacity(theme.centerChannelColor, 0.56),
                  ...typography('Body', 100, 'SemiBold'),
                ),
                animateToNumber: count,
                animationDuration: Duration(milliseconds: 450),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> getStyleSheet(ThemeData theme) {
    return {
      'count': TextStyle(
        color: changeOpacity(theme.centerChannelColor, 0.56),
        ...typography('Body', 100, 'SemiBold'),
      ),
      'countContainer': EdgeInsets.only(right: 5),
      'countHighlight': TextStyle(
        color: theme.buttonBg,
      ),
      'customEmojiStyle': TextStyle(color: Colors.black),
      'emoji': EdgeInsets.symmetric(horizontal: 5),
      'highlight': BoxDecoration(
        color: changeOpacity(theme.buttonBg, 0.08),
      ),
      'reaction': BoxDecoration(
        color: theme.centerChannelBg,
        borderRadius: BorderRadius.circular(4),
      ),
    };
  }
}
