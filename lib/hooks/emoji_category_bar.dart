// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EmojiCategoryBarIcon {
  final String key;
  final String icon;

  EmojiCategoryBarIcon({
    required this.key,
    required this.icon,
  });
}

class EmojiCategoryBar {
  int currentIndex;
  int? selectedIndex;
  List<EmojiCategoryBarIcon>? icons;
  String skinTone;

  EmojiCategoryBar({
    this.currentIndex = 0,
    this.selectedIndex,
    this.icons,
    this.skinTone = 'default',
  });
}

class EmojiCategoryBarNotifier extends ChangeNotifier {
  EmojiCategoryBar _state = EmojiCategoryBar();

  EmojiCategoryBar get state => _state;

  void selectEmojiCategoryBarSection(int? index) {
    _state.selectedIndex = index;
    notifyListeners();
  }

  void setEmojiCategoryBarSection(int index) {
    _state.currentIndex = index;
    notifyListeners();
  }

  void setEmojiCategoryBarIcons(List<EmojiCategoryBarIcon>? icons) {
    _state.icons = icons;
    notifyListeners();
  }

  void setEmojiSkinTone(String skinTone) {
    _state.skinTone = skinTone;
    notifyListeners();
  }
}

class EmojiSkinToneNotifier extends ChangeNotifier {
  String _skinTone = 'default';

  String get skinTone => _skinTone;

  void setEmojiSkinTone(String skinTone) {
    _skinTone = skinTone;
    notifyListeners();
  }
}

void selectEmojiCategoryBarSection(BuildContext context, int? index) {
  Provider.of<EmojiCategoryBarNotifier>(context, listen: false).selectEmojiCategoryBarSection(index);
}

void setEmojiCategoryBarSection(BuildContext context, int index) {
  Provider.of<EmojiCategoryBarNotifier>(context, listen: false).setEmojiCategoryBarSection(index);
}

void setEmojiCategoryBarIcons(BuildContext context, List<EmojiCategoryBarIcon>? icons) {
  Provider.of<EmojiCategoryBarNotifier>(context, listen: false).setEmojiCategoryBarIcons(icons);
}

void setEmojiSkinTone(BuildContext context, String skinTone) {
  Provider.of<EmojiCategoryBarNotifier>(context, listen: false).setEmojiSkinTone(skinTone);
  Provider.of<EmojiSkinToneNotifier>(context, listen: false).setEmojiSkinTone(skinTone);
}

class EmojiCategoryBarProvider extends StatelessWidget {
  final Widget child;

  EmojiCategoryBarProvider({required this.child});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => EmojiCategoryBarNotifier()),
        ChangeNotifierProvider(create: (_) => EmojiSkinToneNotifier()),
      ],
      child: child,
    );
  }
}

class EmojiCategoryBarConsumer extends StatelessWidget {
  final Widget Function(BuildContext context, EmojiCategoryBar state, Widget? child) builder;
  final Widget? child;

  EmojiCategoryBarConsumer({required this.builder, this.child});

  @override
  Widget build(BuildContext context) {
    return Consumer<EmojiCategoryBarNotifier>(
      builder: (context, notifier, child) => builder(context, notifier.state, child),
      child: child,
    );
  }
}

class EmojiSkinToneConsumer extends StatelessWidget {
  final Widget Function(BuildContext context, String skinTone, Widget? child) builder;
  final Widget? child;

  EmojiSkinToneConsumer({required this.builder, this.child});

  @override
  Widget build(BuildContext context) {
    return Consumer<EmojiSkinToneNotifier>(
      builder: (context, notifier, child) => builder(context, notifier.skinTone, child),
      child: child,
    );
  }
}
