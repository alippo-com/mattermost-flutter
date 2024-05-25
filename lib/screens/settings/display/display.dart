// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:mattermost_flutter/types/database/user_model.dart';
import 'package:mattermost_flutter/screens/navigation.dart';
import 'package:mattermost_flutter/screens/settings/config.dart';
import 'package:mattermost_flutter/utils/tap.dart';
import 'package:mattermost_flutter/utils/user.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

const CRT_FORMAT = [
  {
    'id': 'display_settings.crt.on',
    'defaultMessage': 'On',
  },
  {
    'id': 'display_settings.crt.off',
    'defaultMessage': 'Off',
  },
];

const TIME_FORMAT = [
  {
    'id': 'display_settings.clock.standard',
    'defaultMessage': '12-hour',
  },
  {
    'id': 'display_settings.clock.military',
    'defaultMessage': '24-hour',
  },
];

const TIMEZONE_FORMAT = [
  {
    'id': 'display_settings.tz.auto',
    'defaultMessage': 'Auto',
  },
  {
    'id': 'display_settings.tz.manual',
    'defaultMessage': 'Manual',
  },
];

class Display extends HookWidget {
  final String componentId;
  final UserModel? currentUser;
  final bool hasMilitaryTimeFormat;
  final bool isCRTEnabled;
  final bool isCRTSwitchEnabled;
  final bool isThemeSwitchingEnabled;

  Display({
    required this.componentId,
    this.currentUser,
    required this.hasMilitaryTimeFormat,
    required this.isCRTEnabled,
    required this.isCRTSwitchEnabled,
    required this.isThemeSwitchingEnabled,
  });

  @override
  Widget build(BuildContext context) {
    final intl = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final timezone = useMemo(
        () => getUserTimezoneProps(currentUser!), [currentUser?.timezone]);

    final goToThemeSettings = preventDoubleTap(() {
      final screen = 'SETTINGS_DISPLAY_THEME';
      final title = intl.display_settings_theme;
      goToScreen(context, screen, title);
    });

    final goToClockDisplaySettings = preventDoubleTap(() {
      final screen = 'SETTINGS_DISPLAY_CLOCK';
      final title = intl.display_settings_clockDisplay;
      gotoSettingsScreen(context, screen, title);
    });

    final goToTimezoneSettings = preventDoubleTap(() {
      final screen = 'SETTINGS_DISPLAY_TIMEZONE';
      final title = intl.display_settings_timezone;
      gotoSettingsScreen(context, screen, title);
    });

    final goToCRTSettings = preventDoubleTap(() {
      final screen = 'SETTINGS_DISPLAY_CRT';
      final title = intl.display_settings_crt;
      gotoSettingsScreen(context, screen, title);
    });

    final close = useCallback(() {
      popTopScreen(context, componentId);
    }, [componentId]);

    useAndroidHardwareBackHandler(context, componentId, close);

    return SettingContainer(
      testID: 'display_settings',
      children: [
        if (isThemeSwitchingEnabled)
          SettingItem(
            optionName: 'theme',
            onPress: goToThemeSettings,
            info: theme.brightness == Brightness.dark ? 'Dark' : 'Light',
            testID: 'display_settings.theme.option',
          ),
        SettingItem(
          optionName: 'clock',
          onPress: goToClockDisplaySettings,
          info: intl.display_settings_clockFormat(
              hasMilitaryTimeFormat ? TIME_FORMAT[1]['defaultMessage']! : TIME_FORMAT[0]['defaultMessage']!),
          testID: 'display_settings.clock_display.option',
        ),
        SettingItem(
          optionName: 'timezone',
          onPress: goToTimezoneSettings,
          info: intl.display_settings_timezoneFormat(
              timezone.useAutomaticTimezone ? TIMEZONE_FORMAT[0]['defaultMessage']! : TIMEZONE_FORMAT[1]['defaultMessage']!),
          testID: 'display_settings.timezone.option',
        ),
        if (isCRTSwitchEnabled)
          SettingItem(
            optionName: 'crt',
            onPress: goToCRTSettings,
            info: intl.display_settings_crtFormat(
                isCRTEnabled ? CRT_FORMAT[0]['defaultMessage']! : CRT_FORMAT[1]['defaultMessage']!),
            testID: 'display_settings.crt.option',
          ),
      ],
    );
  }
}
