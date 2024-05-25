import 'package:flutter/material.dart';
import 'package:mattermost_flutter/components/option_menus.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/types/screens/gallery.dart';
import 'package:mattermost_flutter/types/file_result.dart';

const double openDownMargin = 64.0;

class TabletOptionsProps {
  final FileInfo fileInfo;
  final int numOptions;
  final bool openUp;
  final Function(GalleryAction) setAction;
  final Function(bool) setShowOptions;
  final XyOffset xyOffset;

  TabletOptionsProps({
    required this.fileInfo,
    required this.numOptions,
    this.openUp = false,
    required this.setAction,
    required this.setShowOptions,
    required this.xyOffset,
  });
}

class TabletOptions extends StatefulWidget {
  final TabletOptionsProps props;

  TabletOptions({required this.props});

  @override
  _TabletOptionsState createState() => _TabletOptionsState();
}

class _TabletOptionsState extends State<TabletOptions> {
  void toggleOverlay() {
    widget.props.setShowOptions(false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final styles = getStyleSheet(theme);

    final overlayStyle = {
      'marginTop': widget.props.openUp ? 0.0 : openDownMargin,
      'top': widget.props.xyOffset.y - (widget.props.openUp ? ITEM_HEIGHT * widget.props.numOptions : 0.0),
      'right': widget.props.xyOffset.x,
    };

    return Stack(
      children: [
        GestureDetector(
          onTap: toggleOverlay,
          child: Container(
            color: Colors.transparent, // Equivalent to backdropStyle in Overlay
          ),
        ),
        Positioned(
          top: overlayStyle['top'],
          right: overlayStyle['right'],
          child: Container(
            width: 252,
            padding: EdgeInsets.only(left: 20),
            decoration: BoxDecoration(
              color: theme.centerChannelBg,
              border: Border.all(color: changeOpacity(theme.centerChannelColor, 0.16)),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: theme.centerChannelColor.withOpacity(0.12),
                  offset: Offset(0, 8),
                  blurRadius: 24,
                ),
              ],
            ),
            child: OptionMenus(
              setAction: widget.props.setAction,
              fileInfo: widget.props.fileInfo,
            ),
          ),
        ),
      ],
    );
  }

  Map<String, dynamic> getStyleSheet(ThemeData theme) {
    return {
      'tablet': {
        'backgroundColor': theme.centerChannelBg,
        'borderColor': changeOpacity(theme.centerChannelColor, 0.16),
        'borderRadius': 8.0,
        'borderWidth': 1.0,
        'paddingLeft': 20.0,
        'position': 'absolute',
        'right': 20.0,
        'width': 252.0,
        'marginRight': 20.0,
        'shadowColor': theme.centerChannelColor,
        'shadowOffset': Offset(0, 8),
        'shadowOpacity': 0.12,
        'shadowRadius': 24.0,
      },
      'backDrop': {'opacity': 0.0},
    };
  }
}
