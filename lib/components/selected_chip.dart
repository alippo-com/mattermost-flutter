import 'package:flutter/material.dart';
import 'package:mattermost_flutter/components/compass_icon.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/strings.dart';
import 'package:provider/provider.dart';

class SelectedChip extends StatelessWidget {
  final String id;
  final String text;
  final Widget? extra;
  final void Function(String id) onRemove;
  final String? testID;
  final BoxDecoration? containerStyle;

  static const double USER_CHIP_HEIGHT = 32;
  static const double USER_CHIP_BOTTOM_MARGIN = 8;
  static const int FADE_DURATION = 100;

  SelectedChip({
    required this.id,
    required this.text,
    this.extra,
    required this.onRemove,
    this.testID,
    this.containerStyle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeNotifier>(context).currentTheme;
    final style = getStyleFromTheme(theme);
    final dimensions = MediaQuery.of(context).size;

    final containerStyles = [style.container, containerStyle];

    void onPress() {
      onRemove(id);
    }

    return AnimatedContainer(
      duration: Duration(milliseconds: FADE_DURATION),
      decoration: BoxDecoration(
        color: changeOpacity(theme.centerChannelColor, 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      margin: EdgeInsets.only(bottom: USER_CHIP_BOTTOM_MARGIN, right: 8),
      padding: EdgeInsets.symmetric(horizontal: 7),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (extra != null) extra!,
          Container(
            constraints: BoxConstraints(maxWidth: dimensions.width * 0.70),
            child: Text(
              nonBreakingString(text),
              style: TextStyle(
                color: theme.centerChannelColor,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          GestureDetector(
            onTap: onPress,
            child: CompassIcon(
              name: 'close-circle',
              size: 18,
              color: changeOpacity(theme.centerChannelColor, 0.32),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> getStyleFromTheme(ThemeData theme) {
    return {
      'container': BoxDecoration(
        color: changeOpacity(theme.centerChannelColor, 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      'text': TextStyle(
        color: theme.centerChannelColor,
        fontWeight: FontWeight.w600,
      ),
      'remove': {},
    };
  }
}

String nonBreakingString(String text) {
  return text.replaceAll(' ', '\u00A0');
}
