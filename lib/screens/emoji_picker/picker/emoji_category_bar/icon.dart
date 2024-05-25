// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:mattermost_flutter/components/compass_icon.dart';
import 'package:mattermost_flutter/utils/tap.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/types/theme.dart';

class EmojiCategoryBarIcon extends StatelessWidget {
  final int currentIndex;
  final String icon;
  final int index;
  final Function(int) scrollToIndex;
  final Theme theme;

  EmojiCategoryBarIcon({
    required this.currentIndex,
    required this.icon,
    required this.index,
    required this.scrollToIndex,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final style = _getStyleSheet(theme);
    final onPress = preventDoubleTap(() => scrollToIndex(index));

    return GestureDetector(
      onTap: onPress,
      child: Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: currentIndex == index ? style.selectedContainer : null,
        child: CompassIcon(
          name: icon,
          size: 20,
          color: currentIndex == index ? style.selected.color : style.icon.color,
        ),
      ),
    );
  }

  _StyleSheet _getStyleSheet(Theme theme) {
    return _StyleSheet(
      container: BoxDecoration(),
      icon: TextStyle(color: changeOpacity(theme.centerChannelColor, 0.56)),
      selectedContainer: BoxDecoration(
        color: changeOpacity(theme.buttonBg, 0.08),
        borderRadius: BorderRadius.circular(4),
      ),
      selected: TextStyle(color: theme.buttonBg),
    );
  }
}

class _StyleSheet {
  final BoxDecoration container;
  final TextStyle icon;
  final BoxDecoration selectedContainer;
  final TextStyle selected;

  _StyleSheet({
    required this.container,
    required this.icon,
    required this.selectedContainer,
    required this.selected,
  });
}
