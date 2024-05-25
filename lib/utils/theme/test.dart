// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:mattermost_flutter/constants.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:test/test.dart';

void main() {
  final themes = Preferences.THEMES;

  group('getKeyboardAppearanceFromTheme', () {
    test('should return "light" keyboard appearance for centerChannelBg="#ffffff"', () {
      final keyboardAppearance = getKeyboardAppearanceFromTheme(themes.denim);
      expect(keyboardAppearance, equals('light'));
    });

    test('should return "light" keyboard appearance for centerChannelBg="#ffffff"', () {
      final keyboardAppearance = getKeyboardAppearanceFromTheme(themes.sapphire);
      expect(keyboardAppearance, equals('light'));
    });

    test('should return "dark" keyboard appearance for centerChannelBg="#ffffff"', () {
      final keyboardAppearance = getKeyboardAppearanceFromTheme(themes.quartz);
      expect(keyboardAppearance, equals('light'));
    });

    test('should return "dark" keyboard appearance for centerChannelBg="#0a111f"', () {
      final keyboardAppearance = getKeyboardAppearanceFromTheme(themes.indigo);
      expect(keyboardAppearance, equals('dark'));
    });

    test('should return "dark" keyboard appearance for centerChannelBg="#090a0b"', () {
      final keyboardAppearance = getKeyboardAppearanceFromTheme(themes.onyx);
      expect(keyboardAppearance, equals('dark'));
    });
  });
}
