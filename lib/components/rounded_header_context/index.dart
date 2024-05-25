import 'package:flutter/material.dart';
import 'package:mattermost_flutter/types/theme.dart';
import 'package:mattermost_flutter/utils/theme.dart';

class RoundedHeaderContext extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = useTheme(context);
    final styles = getStyleSheet(theme);

    return Container(
      decoration: BoxDecoration(
        color: theme.sidebarBg,
        position: DecorationPosition.background,
      ),
      height: 40,
      width: double.infinity,
      child: Container(
        decoration: BoxDecoration(
          color: theme.centerChannelBg,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(12),
          ),
        ),
        child: SizedBox.expand(),
      ),
    );
  }

  ThemeData useTheme(BuildContext context) {
    // Assume we have a method to get theme data
    return Theme.of(context);
  }

  Map<String, dynamic> getStyleSheet(ThemeData theme) {
    return {
      'container': BoxDecoration(
        color: theme.sidebarBg,
      ),
      'content': BoxDecoration(
        color: theme.centerChannelBg,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(12),
        ),
      ),
    };
  }
}
