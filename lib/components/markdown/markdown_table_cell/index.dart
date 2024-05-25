import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme.dart';

class MarkdownTableCell extends StatelessWidget {
  final String align;
  final Widget children;
  final bool isLastCell;

  static const double CELL_MIN_WIDTH = 96;
  static const double CELL_MAX_WIDTH = 192;

  MarkdownTableCell({
    required this.align,
    required this.children,
    required this.isLastCell,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeModel>(context);
    final style = _getStyleSheet(theme);

    List<BoxDecoration> cellStyle = [style['cell']];
    if (!isLastCell) {
      cellStyle.add(style['cellRightBorder']);
    }

    BoxDecoration? textStyle = null;
    if (align == 'center') {
      textStyle = style['alignCenter'];
    } else if (align == 'right') {
      textStyle = style['alignRight'];
    }

    return Container(
      decoration: BoxDecoration(
        // Combine cellStyle and textStyle
      ),
      child: Container(
        decoration: style['textContainer'],
        child: children,
      ),
    );
  }

  Map<String, BoxDecoration> _getStyleSheet(ThemeModel theme) {
    return {
      'cell': BoxDecoration(
        border: Border.all(color: changeOpacity(theme.centerChannelColor, 0.2)),
      ),
      'textContainer': BoxDecoration(
        // Add other properties as needed
      ),
      'cellRightBorder': BoxDecoration(
        border: Border(right: BorderSide(width: 1)),
      ),
      'alignCenter': BoxDecoration(
        alignment: Alignment.center,
      ),
      'alignRight': BoxDecoration(
        alignment: Alignment.centerRight,
      ),
    };
  }

  Color changeOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }
}
