
import 'package:flutter/material.dart';

import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'icon.dart'; // Assuming this is a custom widget similar to EmojiCategoryBarIcon

class EmojiCategoryBar extends StatelessWidget {
  final Function(int?)? onSelect;

  EmojiCategoryBar({this.onSelect});

  @override
  Widget build(BuildContext context) {
    final theme = useTheme(context); // Custom hook to get theme
    final styles = _getStyleSheetFromTheme(theme);
    final emojiCategoryBar = useEmojiCategoryBar(context);
    final currentIndex = emojiCategoryBar.currentIndex;
    final icons = emojiCategoryBar.icons;

    void scrollToIndex(int index) {
      if (onSelect != null) {
        onSelect!(index);
        return;
      }

      selectEmojiCategoryBarSection(index);
    }

    if (icons == null) {
      return SizedBox.shrink();
    }

    return Container(
      key: Key('emoji_picker.category_bar'),
      decoration: BoxDecoration(
        color: theme.centerChannelBg,
        border: Border(
          top: BorderSide(
            color: changeOpacity(theme.centerChannelColor, 0.08),
            width: 1,
          ),
        ),
      ),
      height: 55,
      padding: EdgeInsets.only(left: 12, right: 12, top: 11),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: icons.map<Widget>((icon) {
          int index = icons.indexOf(icon);
          return EmojiCategoryBarIcon(
            currentIndex: currentIndex,
            key: Key(icon.key),
            icon: icon.icon,
            index: index,
            scrollToIndex: scrollToIndex,
            theme: theme,
          );
        }).toList(),
      ),
    );
  }

  Map<String, TextStyle> _getStyleSheetFromTheme(ThemeData theme) {
    return {
      'sectionTitle': TextStyle(
        color: changeOpacity(theme.centerChannelColor, 0.2),
        textTransform: TextTransform.uppercase,
        ...typography('Heading', 75, FontWeight.w600),
      ),
    };
  }
}
