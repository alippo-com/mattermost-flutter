import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mattermost_flutter/constants/screens.dart';
import 'package:mattermost_flutter/utils/timezone.dart';
import 'package:mattermost_flutter/utils/user.dart';
import 'package:mattermost_flutter/components/settings/container.dart';
import 'package:mattermost_flutter/components/settings/option.dart';
import 'package:mattermost_flutter/components/settings/separator.dart';
import 'package:mattermost_flutter/utils/tap.dart';
import 'package:mattermost_flutter/screens/navigation.dart';
import 'package:mattermost_flutter/actions/remote/user.dart';
import 'package:mattermost_flutter/context/server.dart';
import 'package:mattermost_flutter/hooks/android_back_handler.dart';
import 'package:mattermost_flutter/hooks/navigate_back.dart';

class DisplayTimezone extends StatefulWidget {
  final UserModel? currentUser;
  final AvailableScreens componentId;

  DisplayTimezone({
    this.currentUser,
    required this.componentId,
  });

  @override
  _DisplayTimezoneState createState() => _DisplayTimezoneState();
}

class _DisplayTimezoneState extends State<DisplayTimezone> {
  late Map<String, dynamic> initialTimezone;
  late Map<String, dynamic> userTimezone;
  late String serverUrl;

  @override
  void initState() {
    super.initState();
    serverUrl = useServerUrl();
    initialTimezone = getUserTimezoneProps(widget.currentUser);
    userTimezone = Map<String, dynamic>.from(initialTimezone);
  }

  void updateAutomaticTimezone(bool useAutomaticTimezone) {
    final automaticTimezone = getDeviceTimezone();
    setState(() {
      userTimezone = {
        ...userTimezone,
        'useAutomaticTimezone': useAutomaticTimezone,
        'automaticTimezone': automaticTimezone,
      };
    });
  }

  void updateManualTimezone(String mtz) {
    setState(() {
      userTimezone = {
        'useAutomaticTimezone': false,
        'automaticTimezone': '',
        'manualTimezone': mtz,
      };
    });
  }

  void goToSelectTimezone() {
    preventDoubleTap(() {
      final screen = Screens.SETTINGS_DISPLAY_TIMEZONE_SELECT;
      final title = Intl.message('Select Timezone', name: 'settings_display.timezone.select');

      final passProps = {
        'currentTimezone': userTimezone['manualTimezone'] ?? initialTimezone['manualTimezone'] ?? initialTimezone['automaticTimezone'],
        'onBack': updateManualTimezone,
      };

      goToScreen(screen, title, passProps);
    });
  }

  void close() {
    popTopScreen(widget.componentId);
  }

  void saveTimezone() {
    final canSave = initialTimezone['useAutomaticTimezone'] != userTimezone['useAutomaticTimezone'] ||
        initialTimezone['automaticTimezone'] != userTimezone['automaticTimezone'] ||
        initialTimezone['manualTimezone'] != userTimezone['manualTimezone'];

    if (canSave) {
      final timeZone = {
        'useAutomaticTimezone': userTimezone['useAutomaticTimezone'].toString(),
        'automaticTimezone': userTimezone['automaticTimezone'],
        'manualTimezone': userTimezone['manualTimezone'],
      };

      updateMe(serverUrl, {'timezone': timeZone});
    }

    close();
  }

  @override
  Widget build(BuildContext context) {
    useBackNavigation(saveTimezone);
    useAndroidHardwareBackHandler(widget.componentId, saveTimezone);

    final toggleDesc = userTimezone['useAutomaticTimezone']
        ? getTimezoneRegion(userTimezone['automaticTimezone'])
        : Intl.message('Off', name: 'settings_display.timezone.off');

    return SettingContainer(
      testID: 'timezone_display_settings',
      children: [
        SettingOption(
          action: updateAutomaticTimezone,
          description: toggleDesc,
          label: Intl.message('Set automatically', name: 'settings_display.timezone.automatically'),
          selected: userTimezone['useAutomaticTimezone'],
          testID: 'timezone_display_settings.automatic.option',
          type: 'toggle',
        ),
        SettingSeparator(),
        if (!userTimezone['useAutomaticTimezone'])
          SettingOption(
            action: goToSelectTimezone,
            info: getTimezoneRegion(userTimezone['manualTimezone']),
            label: Intl.message('Change timezone', name: 'settings_display.timezone.manual'),
            testID: 'timezone_display_settings.manual.option',
            type: 'arrow',
          ),
      ],
    );
  }
}