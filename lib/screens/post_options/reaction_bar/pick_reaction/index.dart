import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mattermost_flutter/components/compass_icon.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/constants/reaction_picker.dart';

class PickReaction extends StatelessWidget {
  final VoidCallback openEmojiPicker;
  final double width;
  final double height;

  PickReaction({
    required this.openEmojiPicker,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeNotifier>(context).getTheme();
    final styles = _getStyleSheet(theme);

    return GestureDetector(
      onTap: openEmojiPicker,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: changeOpacity(theme.centerChannelColor, 0.04),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: CompassIcon(
            name: 'emoticon-plus-outline',
            style: TextStyle(
              fontSize: LARGE_ICON_SIZE,
              color: changeOpacity(theme.centerChannelColor, 0.56),
            ),
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> _getStyleSheet(ThemeData theme) {
    return {
      'container': BoxDecoration(
        color: changeOpacity(theme.centerChannelColor, 0.04),
        borderRadius: BorderRadius.circular(4),
      ),
      'highlight': BoxDecoration(
        color: changeOpacity(theme.buttonBg, 0.08),
        borderRadius: BorderRadius.circular(4),
      ),
      'icon': TextStyle(
        fontSize: LARGE_ICON_SIZE,
        color: changeOpacity(theme.centerChannelColor, 0.56),
      ),
    };
  }
}

double changeOpacity(Color color, double opacity) {
  return color.withOpacity(opacity);
}
