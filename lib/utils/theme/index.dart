// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:deep_equal/deep_equal.dart';
import 'package:deepmerge/deepmerge.dart';
import 'package:flutter/material.dart';
import 'package:tinycolor2/tinycolor2.dart';

import 'package:mattermost_flutter/constants/screens.dart';
import 'package:mattermost_flutter/store/ephemeral_store.dart';
import 'package:mattermost_flutter/utils/navigation.dart';
import 'package:mattermost_flutter/types/global/styles.dart';

final RegExp rgbPattern = RegExp(r'^rgba?\((\d+),(\d+),(\d+)(?:,([\d.]+))?\)$');

Map<String, double> getComponents(String inColor) {
  String color = inColor;

  // RGB color
  final match = rgbPattern.firstMatch(color);
  if (match != null) {
    return {
      'red': double.parse(match.group(1)!),
      'green': double.parse(match.group(2)!),
      'blue': double.parse(match.group(3)!),
      'alpha': match.group(4) != null ? double.parse(match.group(4)!) : 1,
    };
  }

  // Hex color
  if (color[0] == '#') {
    color = color.substring(1);
  }

  if (color.length == 3) {
    final tempColor = color;
    color = '';

    color += tempColor[0] + tempColor[0];
    color += tempColor[1] + tempColor[1];
    color += tempColor[2] + tempColor[2];
  }

  return {
    'red': int.parse(color.substring(0, 2), radix: 16).toDouble(),
    'green': int.parse(color.substring(2, 4), radix: 16).toDouble(),
    'blue': int.parse(color.substring(4, 6), radix: 16).toDouble(),
    'alpha': 1,
  };
}

Function makeStyleSheetFromTheme<T extends NamedStyles<T>>(T Function(Theme) getStyleFromTheme) {
  Theme? lastTheme;
  T? style;
  return (Theme theme) {
    if (style == null || theme != lastTheme) {
      style = getStyleFromTheme(theme);
      lastTheme = theme;
    }

    return style!;
  };
}

String changeOpacity(String oldColor, double opacity) {
  final components = getComponents(oldColor);
  return 'rgba(${components['red']},${components['green']},${components['blue']},${components['alpha']! * opacity})';
}

List<T> concatStyles<T>(List<T> styles) {
  return styles.expand((style) => style).toList();
}

void setNavigatorStyles(String componentId, Theme theme, [Options additionalOptions = const Options(), String? statusBarColor]) {
  final isDark = TinyColor(statusBarColor ?? theme.sidebarBg).isDark();
  final options = Options(
    topBar: TopBar(
      title: Title(color: theme.sidebarHeaderTextColor),
      background: Background(color: theme.sidebarBg),
      leftButtonColor: theme.sidebarHeaderTextColor,
      rightButtonColor: theme.sidebarHeaderTextColor,
    ),
    statusBar: StatusBar(
      backgroundColor: theme.sidebarBg,
      style: isDark ? StatusBarStyle.light : StatusBarStyle.dark,
    ),
  );

  if (SCREENS_AS_BOTTOM_SHEET.contains(componentId)) {
    options.topBar = TopBar(
      leftButtonColor: changeOpacity(theme.centerChannelColor, 0.56),
      background: Background(color: theme.centerChannelBg),
      title: Title(color: theme.centerChannelColor),
    );
  }

  if (!SCREENS_WITH_TRANSPARENT_BACKGROUND.contains(componentId) && !SCREENS_AS_BOTTOM_SHEET.contains(componentId)) {
    options.layout = Layout(
      componentBackgroundColor: theme.centerChannelBg,
    );
  }

  if (!MODAL_SCREENS_WITHOUT_BACK.contains(componentId) && !SCREENS_AS_BOTTOM_SHEET.contains(componentId)) {
    options.topBar.backButton = BackButton(color: theme.sidebarHeaderTextColor);
  }
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: theme.sidebarBg,
    statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
  ));

  final mergeOptions = merge(options, additionalOptions);

  mergeNavigationOptions(componentId, mergeOptions);
}

void setNavigationStackStyles(Theme theme) {
  NavigationStore.getScreensInStack().forEach((componentId) {
    if (!appearanceControlledScreens.contains(componentId)) {
      setNavigatorStyles(componentId, theme);
    }
  });
}

String getKeyboardAppearanceFromTheme(Theme theme) {
  return TinyColor(theme.centerChannelBg).isLight() ? 'light' : 'dark';
}

int hexToHue(String hexColor) {
  final components = getComponents(hexColor);
  final red = components['red']! / 255;
  final green = components['green']! / 255;
  final blue = components['blue']! / 255;

  final channelMax = [red, green, blue].reduce(max);
  final channelMin = [red, green, blue].reduce(min);
  final delta = channelMax - channelMin;
  var hue = 0.0;

  if (delta == 0) {
    hue = 0;
  } else if (channelMax == red) {
    hue = ((green - blue) / delta) % 6;
  } else if (channelMax == green) {
    hue = ((blue - red) / delta) + 2;
  } else {
    hue = ((red - green) / delta) + 4;
  }

  hue = (hue * 60).roundToDouble();

  if (hue < 0) {
    hue += 360;
  }

  return hue.toInt();
}

double blendComponent(double background, double foreground, double opacity) {
  return ((1 - opacity) * background) + (opacity * foreground);
}

String blendColors(String background, String foreground, double opacity, [bool hex = false]) {
  final backgroundComponents = getComponents(background);
  final foregroundComponents = getComponents(foreground);

  final red = blendComponent(backgroundComponents['red']!, foregroundComponents['red']!, opacity).floor();
  final green = blendComponent(backgroundComponents['green']!, foregroundComponents['green']!, opacity).floor();
  final blue = blendComponent(backgroundComponents['blue']!, foregroundComponents['blue']!, opacity).floor();
  final alpha = blendComponent(backgroundComponents['alpha']!, foregroundComponents['alpha']!, opacity);

  if (hex) {
    final r = red.toRadixString(16).padLeft(2, '0');
    final g = green.toRadixString(16).padLeft(2, '0');
    final b = blue.toRadixString(16).padLeft(2, '0');

    return '#${r + g + b}';
  }

  return 'rgba(${red},${green},${blue},${alpha})';
}

final Map<String, String> themeTypeMap = {
  'Mattermost': 'denim',
  'Organization': 'sapphire',
  'Mattermost Dark': 'indigo',
  'Windows Dark': 'onyx',
  'Denim': 'denim',
  'Sapphire': 'sapphire',
  'Quartz': 'quartz',
  'Indigo': 'indigo',
  'Onyx': 'onyx',
  'custom': 'custom',
};

Theme setThemeDefaults(ExtendedTheme theme) {
  final themes = Preferences.THEMES as Map<String, ExtendedTheme>;
  final defaultTheme = themes['denim']!;

  final processedTheme = {...theme};

  if (theme.type != null && theme.type != 'custom' && themeTypeMap.containsKey(theme.type)) {
    return Preferences.THEMES[themeTypeMap[theme.type]]!;
  }

  for (final key in defaultTheme.keys) {
    if (theme[key] != null) {
      processedTheme[key] = theme[key]!.toLowerCase();
    }
  }

  for (final property in defaultTheme.keys) {
    if (property == 'type' || (property == 'sidebarTeamBarBg' && theme.sidebarHeaderBg != null)) {
      continue;
    }
    if (theme[property] == null) {
      processedTheme[property] = defaultTheme[property];
    }

    if (theme['mentionBg'] == null && theme['mentionBj'] != null) {
      processedTheme['mentionBg'] = theme['mentionBj'];
    }
  }

  if (theme['sidebarTeamBarBg'] == null && theme['sidebarHeaderBg'] != null) {
    processedTheme['sidebarTeamBarBg'] = blendColors(theme['sidebarHeaderBg']!, '#000000', 0.2, true);
  }

  return processedTheme;
}

void updateThemeIfNeeded(Theme theme, [bool force = false]) {
  final storedTheme = EphemeralStore.theme;
  if (storedTheme != theme || force) {
    EphemeralStore.theme = theme;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setNavigationStackStyles(theme);
    });
  }
}
