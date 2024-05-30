import 'package:flutter/material.dart';
import 'package:mattermost_flutter/constants.dart';
import 'package:mattermost_flutter/types/screens/navigation.dart';
import 'package:mattermost_flutter/utils/tap.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/components/compass_icon.dart';
import 'package:mattermost_flutter/components/settings/container.dart';
import 'package:mattermost_flutter/components/settings/item.dart';
import 'package:mattermost_flutter/actions/remote/command.dart';
import 'package:mattermost_flutter/context/server.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/hooks/navigation_button_pressed.dart';
import 'package:mattermost_flutter/screens/settings/report_problem.dart';

class Settings extends StatefulWidget {
  final AvailableScreens componentId;
  final String helpLink;
  final bool showHelp;
  final String siteName;

  Settings({
    required this.componentId,
    required this.helpLink,
    required this.showHelp,
    required this.siteName,
  });

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  late Theme theme;
  late String serverUrl;
  late String serverDisplayName;
  late String serverName;

  @override
  void initState() {
    super.initState();
    theme = useTheme();
    serverUrl = useServerUrl();
    serverDisplayName = useServerDisplayName();
    serverName = widget.siteName.isNotEmpty ? widget.siteName : serverDisplayName;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setButtons(widget.componentId, leftButtons: [
        IconButton(
          icon: CompassIcon.getImageSourceSync('close', 24, theme.centerChannelColor),
          onPressed: _close,
        ),
      ]);
    });

    useAndroidHardwareBackHandler(widget.componentId, _close);
    useNavButtonPressed(CLOSE_BUTTON_ID, widget.componentId, _close);
  }

  void _close() {
    dismissModal(componentId: widget.componentId);
  }

  void _goToNotifications() {
    final screen = Screens.SETTINGS_NOTIFICATION;
    final title = 'Notifications';

    goToScreen(screen, title);
  }

  void _goToDisplaySettings() {
    final screen = Screens.SETTINGS_DISPLAY;
    final title = 'Display';

    goToScreen(screen, title);
  }

  void _goToAbout() {
    final screen = Screens.ABOUT;
    final title = 'About $serverName';

    goToScreen(screen, title);
  }

  void _goToAdvancedSettings() {
    final screen = Screens.SETTINGS_ADVANCED;
    final title = 'Advanced Settings';

    goToScreen(screen, title);
  }

  void _openHelp() {
    if (widget.helpLink.isNotEmpty) {
      handleGotoLocation(serverUrl, widget.helpLink);
    }
  }

  @override
  Widget build(BuildContext context) {
    final styles = getStyleSheet(theme);

    return SettingContainer(
      testID: 'settings',
      children: [
        SettingItem(
          onPress: _goToNotifications,
          optionName: 'notification',
          testID: 'settings.notifications.option',
        ),
        SettingItem(
          onPress: _goToDisplaySettings,
          optionName: 'display',
          testID: 'settings.display.option',
        ),
        SettingItem(
          onPress: _goToAdvancedSettings,
          optionName: 'advanced_settings',
          testID: 'settings.advanced_settings.option',
        ),
        SettingItem(
          icon: Icons.info_outline,
          label: 'About $serverName',
          onPress: _goToAbout,
          optionName: 'about',
          testID: 'settings.about.option',
        ),
        if (Platform.isAndroid) Container(
          width: '91%',
          height: 1,
          color: changeOpacity(theme.centerChannelColor, 0.08),
          margin: EdgeInsets.only(top: 20),
        ),
        if (widget.showHelp) SettingItem(
          optionLabelTextStyle: TextStyle(color: theme.linkColor),
          onPress: _openHelp,
          optionName: 'help',
          separator: false,
          testID: 'settings.help.option',
          type: SettingItemType.defaultType,
        ),
        ReportProblem(siteName: widget.siteName),
      ],
    );
  }

  static Map<String, dynamic> getStyleSheet(Theme theme) {
    return {
      'containerStyle': {
        'paddingLeft': 8,
        'marginTop': 12,
      },
      'helpGroup': {
        'width': '91%',
        'backgroundColor': changeOpacity(theme.centerChannelColor, 0.08),
        'height': 1,
        'alignSelf': 'center',
      },
    };
  }
}
