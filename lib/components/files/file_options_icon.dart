
import 'package:flutter/material.dart';
import 'package:mattermost_flutter/components/compass_icon.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/utils/theme.dart';

class FileOptionsIcon extends StatelessWidget {
  final VoidCallback onPress;
  final bool selected;

  const FileOptionsIcon({
    Key? key,
    required this.onPress,
    this.selected = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = useTheme(context);
    final styles = getStyleSheet(theme);

    return GestureDetector(
      onTap: onPress,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: selected ? changeOpacity(theme.buttonBg, 0.08) : null,
        ),
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(7),
        alignment: Alignment.centerRight,
        child: CompassIcon(
          name: 'dots-horizontal',
          color: changeOpacity(theme.centerChannelColor, 0.56),
          size: 18,
        ),
      ),
    );
  }

  Map<String, dynamic> getStyleSheet(ThemeData theme) {
    return {
      'threeDotContainer': BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        margin: EdgeInsets.symmetric(horizontal: 20),
        padding: EdgeInsets.all(7),
        alignment: Alignment.centerRight,
      ),
      'selected': BoxDecoration(
        color: changeOpacity(theme.buttonBg, 0.08),
      ),
    };
  }

  Color changeOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }
}
