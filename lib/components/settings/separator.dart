import 'package:flutter/material.dart';
import 'package:mattermost_flutter/types/theme.dart';
import 'package:mattermost_flutter/utils/theme.dart';

class SettingSeparator extends StatelessWidget {
  final BoxDecoration? lineStyles;
  final bool isGroupSeparator;

  SettingSeparator({this.lineStyles, this.isGroupSeparator = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final styles = _getStyleSheet(theme);

    return Container(
      decoration: lineStyles ?? (isGroupSeparator ? styles['groupSeparator'] : styles['separator']),
      margin: isGroupSeparator ? EdgeInsets.only(bottom: 16) : null,
    );
  }

  Map<String, BoxDecoration> _getStyleSheet(ThemeData theme) {
    final groupSeparator = BoxDecoration(
      color: theme.primaryColor.withOpacity(0.12),
      border: Border(bottom: BorderSide(color: theme.primaryColor.withOpacity(0.12), width: 1)),
    );

    return {
      'separator': BoxDecoration(
        color: theme.primaryColor.withOpacity(0.12),
        border: Border(bottom: BorderSide(color: theme.primaryColor.withOpacity(0.12), width: 1)),
      ),
      'groupSeparator': groupSeparator.copyWith(
        margin: EdgeInsets.only(bottom: 16),
      ),
    };
  }
}
