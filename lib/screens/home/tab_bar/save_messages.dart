import 'package:flutter/material.dart';
import 'package:mattermost_flutter/components/compass_icon.dart';
import 'package:mattermost_flutter/constants/view.dart';
import 'package:mattermost_flutter/utils/theme.dart';

class SaveMessages extends StatelessWidget {
  final bool isFocused;
  final ThemeData theme;

  SaveMessages({required this.isFocused, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: CompassIcon(
        size: BOTTOM_TAB_ICON_SIZE,
        name: 'bookmark-outline',
        color: isFocused ? theme.buttonColor : changeOpacity(theme.primaryColor, 0.48),
      ),
    );
  }
}
