// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/constants/types.dart';

class MarkdownTableRow extends StatelessWidget {
  final bool isFirstRow;
  final bool isLastRow;
  final List<Widget> children;

  MarkdownTableRow({
    required this.isFirstRow,
    required this.isLastRow,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).theme;
    final style = _getStyleSheet(theme);

    List<Widget> rowStyle = [style['row']!];
    if (!isLastRow) {
      rowStyle.add(style['rowBottomBorder']!);
    }

    if (isFirstRow) {
      rowStyle.add(style['rowTopBackground']!);
    }

    if (children.isNotEmpty) {
      children[children.length - 1] = Container(
        child: children[children.length - 1],
        decoration: BoxDecoration(
          border: Border(
            right: BorderSide.none,
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: isLastRow ? BorderSide.none : BorderSide(color: style['rowBottomBorder']!.border!.bottom.color),
        ),
        color: isFirstRow ? style['rowTopBackground']!.color : null,
      ),
      child: Row(
        children: children,
      ),
    );
  }

  Map<String, Decoration> _getStyleSheet(ThemeData theme) {
    return {
      'row': BoxDecoration(
        color: theme.colorScheme.surface,
      ),
      'rowTopBackground': BoxDecoration(
        color: changeOpacity(theme.primaryColor, 0.1),
      ),
      'rowBottomBorder': BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: changeOpacity(theme.primaryColor, 0.2),
            width: 1,
          ),
        ),
      ),
    };
  }
}
