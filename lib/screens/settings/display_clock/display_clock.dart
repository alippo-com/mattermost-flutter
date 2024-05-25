
import 'package:flutter/material.dart';
import 'package:mattermost_flutter/actions/remote/preference.dart';
import 'package:mattermost_flutter/components/settings/block.dart';
import 'package:mattermost_flutter/components/settings/container.dart';
import 'package:mattermost_flutter/components/settings/option.dart';
import 'package:mattermost_flutter/components/settings/separator.dart';
import 'package:mattermost_flutter/constants/preferences.dart';
import 'package:mattermost_flutter/context/server.dart';
import 'package:mattermost_flutter/hooks/android_back_handler.dart';
import 'package:mattermost_flutter/hooks/navigate_back.dart';
import 'package:mattermost_flutter/screens/navigation.dart';
import 'package:mattermost_flutter/types/screens/navigation.dart';
import 'package:mattermost_flutter/utils/i18n.dart';

const CLOCK_TYPE = {
  'NORMAL': 'NORMAL',
  'MILITARY': 'MILITARY',
};

class DisplayClock extends StatefulWidget {
  final AvailableScreens componentId;
  final String currentUserId;
  final bool hasMilitaryTimeFormat;

  DisplayClock({
    required this.componentId,
    required this.currentUserId,
    required this.hasMilitaryTimeFormat,
  });

  @override
  _DisplayClockState createState() => _DisplayClockState();
}

class _DisplayClockState extends State<DisplayClock> {
  late bool isMilitaryTimeFormat;

  @override
  void initState() {
    super.initState();
    isMilitaryTimeFormat = widget.hasMilitaryTimeFormat;
  }

  void onSelectClockPreference(String clockType) {
    setState(() {
      isMilitaryTimeFormat = clockType == CLOCK_TYPE['MILITARY'];
    });
  }

  void saveClockDisplayPreference() {
    if (widget.hasMilitaryTimeFormat != isMilitaryTimeFormat) {
      final timePreference = {
        'category': Preferences.CATEGORIES.DISPLAY_SETTINGS,
        'name': 'use_military_time',
        'user_id': widget.currentUserId,
        'value': '$isMilitaryTimeFormat',
      };

      savePreference(ServerUrlProvider.of(context)!.serverUrl, [timePreference]);
    }

    popTopScreen(widget.componentId);
  }

  @override
  Widget build(BuildContext context) {
    useBackNavigation(context, saveClockDisplayPreference);
    useAndroidHardwareBackHandler(context, widget.componentId, saveClockDisplayPreference);

    return SettingContainer(
      testID: 'clock_display_settings',
      child: SettingBlock(
        disableHeader: true,
        children: [
          SettingOption(
            action: onSelectClockPreference,
            label: I18n.of(context)!.formatMessage(id: 'settings_display.clock.standard', defaultMessage: '12-hour clock'),
            description: I18n.of(context)!.formatMessage(id: 'settings_display.clock.normal.desc', defaultMessage: 'Example: 4:00 PM'),
            selected: !isMilitaryTimeFormat,
            testID: 'clock_display_settings.twelve_hour.option',
            type: 'select',
            value: CLOCK_TYPE['NORMAL'],
          ),
          SettingSeparator(),
          SettingOption(
            action: onSelectClockPreference,
            label: I18n.of(context)!.formatMessage(id: 'settings_display.clock.mz', defaultMessage: '24-hour clock'),
            description: I18n.of(context)!.formatMessage(id: 'settings_display.clock.mz.desc', defaultMessage: 'Example: 16:00'),
            selected: isMilitaryTimeFormat,
            testID: 'clock_display_settings.twenty_four_hour.option',
            type: 'select',
            value: CLOCK_TYPE['MILITARY'],
          ),
          SettingSeparator(),
        ],
      ),
    );
  }
}
