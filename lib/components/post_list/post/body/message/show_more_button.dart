import 'package:flutter/material.dart';
import 'package:mattermost_flutter/components/compass_icon.dart';
import 'package:mattermost_flutter/utils/theme.dart';

class ShowMoreButton extends StatelessWidget {
  final bool highlight;
  final VoidCallback onPress;
  final bool showMore;
  final Theme theme;

  ShowMoreButton({
    required this.highlight,
    required this.onPress,
    required this.showMore,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final style = getStyleSheet(theme);

    String iconName = showMore ? 'chevron-down' : 'chevron-up';

    List<Color> gradientColors = [
      changeOpacity(theme.centerChannelBg, 0),
      changeOpacity(theme.centerChannelBg, 0.75),
      theme.centerChannelBg,
    ];

    if (highlight) {
      gradientColors = [
        changeOpacity(theme.mentionHighlightBg, 0),
        changeOpacity(theme.mentionHighlightBg, 0.15),
        changeOpacity(theme.mentionHighlightBg, 0.5),
      ];
    }

    return Stack(
      children: [
        if (showMore)
          Positioned(
            top: -50,
            width: MediaQuery.of(context).size.width,
            height: 50,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradientColors,
                  stops: [0, 0.7, 1],
                ),
              ),
            ),
          ),
        Container(
          alignment: Alignment.center,
          margin: EdgeInsets.only(top: 10, bottom: 10),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: 10),
                  height: 1,
                  color: changeOpacity(theme.centerChannelColor, 0.2),
                ),
              ),
              GestureDetector(
                onTap: onPress,
                child: Container(
                  height: 44,
                  width: 44,
                  padding: EdgeInsets.only(top: 7),
                  decoration: BoxDecoration(
                    color: theme.centerChannelBg,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: changeOpacity(theme.centerChannelColor, 0.2),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: CompassIcon(
                      name: iconName,
                      size: 28,
                      color: theme.linkColor,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(left: 10),
                  height: 1,
                  color: changeOpacity(theme.centerChannelColor, 0.2),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Map<String, dynamic> getStyleSheet(Theme theme) {
    return {
      'button': {
        'flex': 1,
        'flexDirection': 'row',
      },
      'buttonContainer': {
        'alignItems': 'center',
        'justifyContent': 'center',
        'backgroundColor': theme.centerChannelBg,
        'borderColor': changeOpacity(theme.centerChannelColor, 0.2),
        'borderRadius': 22,
        'borderWidth': 1,
        'height': 44,
        'width': 44,
        'paddingTop': 7,
      },
      'container': {
        'alignItems': 'center',
        'justifyContent': 'center',
        'flex': 1,
        'flexDirection': 'row',
        'position': 'relative',
        'top': 10,
        'marginBottom': 10,
      },
      'dividerLeft': {
        'backgroundColor': changeOpacity(theme.centerChannelColor, 0.2),
        'flex': 1,
        'height': 1,
        'marginRight': 10,
      },
      'dividerRight': {
        'backgroundColor': changeOpacity(theme.centerChannelColor, 0.2),
        'flex': 1,
        'height': 1,
        'marginLeft': 10,
      },
      'gradient': {
        'flex': 1,
        'height': 50,
        'position': 'absolute',
        'top': -50,
        'width': '100%',
      },
      'sign': {
        'color': theme.linkColor,
      },
    };
  }
}
