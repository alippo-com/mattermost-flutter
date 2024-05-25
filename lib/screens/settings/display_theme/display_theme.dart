// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:mattermost_flutter/actions/remote/preference.dart';
import 'package:mattermost_flutter/components/settings/container.dart';
import 'package:mattermost_flutter/constants/preferences.dart';
import 'package:mattermost_flutter/context/server.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/hooks/android_back_handler.dart';
import 'package:mattermost_flutter/screens/navigation.dart';
import 'custom_theme.dart';
import 'theme_tiles.dart';
import 'package:mattermost_flutter/types/screens/navigation.dart';

class DisplayTheme extends StatefulWidget {
  final List<String> allowedThemeKeys;
  final AvailableScreens componentId;
  final String currentTeamId;
  final String currentUserId;

  DisplayTheme({
    required this.allowedThemeKeys,
    required this.componentId,
    required this.currentTeamId,
    required this.currentUserId,
  });

  @override
  _DisplayThemeState createState() => _DisplayThemeState();
}

class _DisplayThemeState extends State<DisplayTheme> {
  late String? newTheme;
  late String initialTheme;

  @override
  void initState() {
    super.initState();
    newTheme = null;
    initialTheme = theme.type!;
    WidgetsBinding.instance!.addPostFrameCallback((_) => checkTheme());
    useAndroidHardwareBackHandler(widget.componentId, onAndroidBack);
  }

  void checkTheme() {
    if (theme.type?.toLowerCase() != newTheme?.toLowerCase()) {
      setThemePreference();
    } else {
      close();
    }
  }

  void setThemePreference() {
    final allowedTheme = widget.allowedThemeKeys.firstWhere(
        (tk) => tk == newTheme,
        orElse: () => initialTheme
    );
    final themeJson = Preferences.THEMES[allowedTheme]!;

    final pref = PreferenceType(
      category: Preferences.CATEGORIES.THEME,
      name: widget.currentTeamId,
      userId: widget.currentUserId,
      value: themeJson,
    );

    savePreference(serverUrl, [pref]);
  }

  void onAndroidBack() {
    setThemePreference();
    close();
  }

  void close() {
    popTopScreen(widget.componentId);
  }

  @override
  Widget build(BuildContext context) {
    return SettingContainer(
      testID: 'theme_display_settings',
      child: Column(
        children: <Widget>[
          ThemeTiles(
            allowedThemeKeys: widget.allowedThemeKeys,
            onThemeChange: (theme) => setState(() => newTheme = theme),
            selectedTheme: theme.type!,
          ),
          if (initialTheme == 'custom')
            CustomTheme(
              setTheme: (theme) => setState(() => newTheme = theme),
              displayTheme: initialTheme,
            ),
        ],
      ),
    );
  }
}
