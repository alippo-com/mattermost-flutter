
import 'package:flutter/material.dart';
import 'package:mattermost_flutter/queries/servers/channel.dart';
import 'package:mattermost_flutter/components/compass_icon.dart';
import 'package:mattermost_flutter/utils/tap.dart';
import 'package:mattermost_flutter/utils/theme.dart';

const double MAX_HEIGHT = 300;
const int MAX_PREVIEW_COLUMNS = 5;
const double CELL_MAX_WIDTH = 100; // Placeholder, replace with actual value
const double CELL_MIN_WIDTH = 50; // Placeholder, replace with actual value

class MarkdownTable extends StatefulWidget {
  final List<Widget> children;
  final int numColumns;
  final ThemeData theme;

  MarkdownTable({
    required this.children,
    required this.numColumns,
    required this.theme,
  });

  @override
  _MarkdownTableState createState() => _MarkdownTableState();
}

class _MarkdownTableState extends State<MarkdownTable> {
  bool? rowsSliced;
  bool? colsSliced;
  late double containerWidth;
  late double contentHeight;
  late double cellWidth;
  late int maxPreviewColumns;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setMaxPreviewColumns(MediaQuery.of(context).size);
    });
  }

  void setMaxPreviewColumns(Size size) {
    setState(() {
      maxPreviewColumns = (size.width / CELL_MIN_WIDTH).floor();
    });
  }

  double getTableWidth({bool isFullView = false}) {
    int columns = widget.numColumns < maxPreviewColumns ? widget.numColumns : maxPreviewColumns;
    return (isFullView || columns == 1) ? columns * CELL_MAX_WIDTH : columns * CELL_MIN_WIDTH;
  }

  void handlePress() {
    final screen = Screens.TABLE;
    final title = 'Table';
    final passProps = {
      'renderAsFlex': shouldRenderAsFlex(true),
      'renderRows': renderRows,
      'width': getTableWidth(isFullView: true),
    };

    goToScreen(screen, title, passProps);
  }

  bool shouldRenderAsFlex({bool isFullView = false}) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
    final bool isLandscape = width > height;

    if (!isFullView && widget.numColumns > 1 && widget.numColumns < 4 && !Device.IS_TABLET) {
      return true;
    }

    if (!isFullView && isLandscape && widget.numColumns == 4) {
      return true;
    }

    if (isFullView && widget.numColumns >= 3 && widget.numColumns <= 4 && !Device.IS_TABLET) {
      return true;
    }

    return false;
  }

  List<Widget> renderRows({bool isFullView = false, bool isPreview = false}) {
    List<Widget> rows = widget.children;

    if (isPreview) {
      rows = rows.take(maxPreviewColumns).toList();
    }

    if (rows.isEmpty) {
      return [];
    }

    rows[rows.length - 1] = Container(
      child: rows[rows.length - 1],
      decoration: BoxDecoration(border: Border(bottom: BorderSide.none)),
    );

    rows[0] = Container(
      child: rows[0],
      decoration: BoxDecoration(color: widget.theme.primaryColor),
    );

    return rows;
  }

  @override
  Widget build(BuildContext context) {
    final double tableWidth = getTableWidth();
    final bool renderAsFlex = shouldRenderAsFlex();
    final List<Widget> previewRows = renderRows(isPreview: true);

    double leftOffset;
    if (renderAsFlex || tableWidth > containerWidth) {
      leftOffset = containerWidth - 20;
    } else {
      leftOffset = tableWidth - 20;
    }

    double expandButtonOffset = leftOffset;
    if (Theme.of(context).platform == TargetPlatform.android) {
      expandButtonOffset -= 10;
    }

    Widget? moreRight;
    if (colsSliced == true || (containerWidth != 0 && tableWidth > containerWidth && !renderAsFlex) || (widget.numColumns > MAX_PREVIEW_COLUMNS)) {
      moreRight = Positioned(
        left: leftOffset,
        child: Container(
          height: contentHeight,
          width: 20,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                widget.theme.colorScheme.surface.withOpacity(0.0),
                widget.theme.colorScheme.surface.withOpacity(0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      );
    }

    Widget? moreBelow;
    if (rowsSliced == true || contentHeight > MAX_HEIGHT) {
      moreBelow = Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: Container(
          height: 20,
          width: containerWidth,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                widget.theme.colorScheme.surface.withOpacity(0.0),
                widget.theme.colorScheme.surface.withOpacity(0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      );
    }

    Widget? expandButton;
    if (expandButtonOffset > 0) {
      expandButton = Positioned(
        left: expandButtonOffset,
        child: GestureDetector(
          onTap: handlePress,
          child: Container(
            height: 34,
            width: 34,
            decoration: BoxDecoration(
              color: widget.theme.canvasColor,
              border: Border.all(color: widget.theme.dividerColor),
              borderRadius: BorderRadius.circular(17),
            ),
            child: Icon(Icons.arrow_drop_down, color: widget.theme.colorScheme.secondary),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: handlePress,
      child: Container(
        padding: EdgeInsets.only(right: 10),
        constraints: BoxConstraints(maxHeight: MAX_HEIGHT),
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: previewRows,
              ),
            ),
            if (moreRight != null) moreRight,
            if (moreBelow != null) moreBelow,
            if (expandButton != null) expandButton,
          ],
        ),
      ),
    );
  }
}
