// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:mattermost_flutter/constants.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/typography.dart';
import 'package:mattermost_flutter/components/compass_icon.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/hooks/device.dart';

import 'theme_thumbnail.dart';

const double TILE_PADDING = 8.0;

class ThemeTile extends StatelessWidget {
  final Function(String) action;
  final String actionValue;
  final Theme theme;
  final Widget label;
  final bool selected;
  final String? testID;
  final Theme activeTheme;

  ThemeTile({
    required this.action,
    required this.actionValue,
    required this.activeTheme,
    required this.label,
    required this.selected,
    this.testID,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = useIsTablet();
    final deviceWidth = MediaQuery.of(context).size.width;

    final tilesPerLine = isTablet ? 4 : 2;
    final fullWidth = isTablet ? deviceWidth - 40 : deviceWidth;

    final layoutStyle = {
      'container': {
        'width': (fullWidth / tilesPerLine) - TILE_PADDING,
      },
      'thumbnail': {
        'width': (fullWidth / tilesPerLine) - (TILE_PADDING + 16),
      },
    };

    void onPressHandler() {
      action(actionValue);
    }

    return GestureDetector(
      onTap: onPressHandler,
      child: Container(
        padding: EdgeInsets.all(TILE_PADDING),
        width: layoutStyle['container']!['width'],
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(bottom: 8),
              child: Stack(
                children: [
                  ThemeThumbnail(
                    borderColorBase: selected ? activeTheme.buttonBg : activeTheme.centerChannelBg,
                    borderColorMix: selected
                        ? activeTheme.buttonBg
                        : changeOpacity(activeTheme.centerChannelColor, 0.16),
                    theme: theme,
                    width: layoutStyle['thumbnail']!['width'],
                  ),
                  if (selected)
                    Positioned(
                      right: 5,
                      bottom: 5,
                      child: CompassIcon(
                        name: 'check-circle',
                        size: 31.2,
                        color: activeTheme.sidebarTextActiveBorder,
                        testID: "${testID}.selected",
                      ),
                    ),
                ],
              ),
            ),
            label,
          ],
        ),
      ),
    );
  }
}

class ThemeTiles extends StatelessWidget {
  final List<String> allowedThemeKeys;
  final Function(String) onThemeChange;
  final String? selectedTheme;

  ThemeTiles({
    required this.allowedThemeKeys,
    required this.onThemeChange,
    this.selectedTheme,
  });

  @override
  Widget build(BuildContext context) {
    final theme = useTheme();
    final styles = getStyleSheet(theme);

    return Container(
      margin: EdgeInsets.only(bottom: 30),
      padding: EdgeInsets.only(left: 8),
      color: theme.centerChannelBg,
      child: Wrap(
        children: allowedThemeKeys.map((themeKey) {
          if (!Preferences.THEMES.containsKey(themeKey) || selectedTheme == null) {
            return Container();
          }

          return ThemeTile(
            key: Key(themeKey),
            label: Text(themeKey, style: styles['label']),
            action: onThemeChange,
            actionValue: themeKey,
            selected: selectedTheme!.toLowerCase() == themeKey.toLowerCase(),
            testID: "theme_display_settings.$themeKey.option",
            theme: Preferences.THEMES[themeKey]!,
            activeTheme: theme,
          );
        }).toList(),
      ),
    );
  }
}

Map<String, dynamic> getStyleSheet(Theme theme) {
  return {
    'label': TextStyle(
      color: theme.centerChannelColor,
      fontSize: Typography.body200,
      textTransform: TextTransform.capitalize,
    ),
  };
}
