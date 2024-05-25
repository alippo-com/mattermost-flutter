import 'package:flutter/material.dart';
import 'package:mattermost_flutter/actions/remote/user.dart';
import 'package:mattermost_flutter/components/floating_text_input_label.dart';
import 'package:mattermost_flutter/components/formatted_text.dart';
import 'package:mattermost_flutter/components/settings/container.dart';
import 'package:mattermost_flutter/components/settings/option.dart';
import 'package:mattermost_flutter/components/settings/separator.dart';
import 'package:mattermost_flutter/constants/general.dart';
import 'package:mattermost_flutter/context/server.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/hooks/android_back_handler.dart';
import 'package:mattermost_flutter/hooks/navigate_back.dart';
import 'package:mattermost_flutter/i18n.dart';
import 'package:mattermost_flutter/screens/navigation.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/typography.dart';
import 'package:mattermost_flutter/utils/user.dart';
import 'package:mattermost_flutter/typings/database/models/servers/user.dart';
import 'package:mattermost_flutter/typings/screens/navigation.dart';

class NotificationAutoResponder extends StatefulWidget {
  final AvailableScreens componentId;
  final UserModel? currentUser;

  NotificationAutoResponder({required this.componentId, this.currentUser});

  @override
  _NotificationAutoResponderState createState() => _NotificationAutoResponderState();
}

class _NotificationAutoResponderState extends State<NotificationAutoResponder> {
  late bool autoResponderActive;
  late String autoResponderMessage;
  late ThemeData theme;
  late String serverUrl;
  late NotificationProps notifyProps;

  @override
  void initState() {
    super.initState();
    theme = useTheme();
    serverUrl = useServerUrl();
    notifyProps = getNotificationProps(widget.currentUser);
    autoResponderActive = widget.currentUser?.status == General.OUT_OF_OFFICE && notifyProps.autoResponderActive == 'true';
    autoResponderMessage = notifyProps.autoResponderMessage ?? t('notification_settings.auto_responder.default_message');
  }

  void close() {
    popTopScreen(widget.componentId);
  }

  void saveAutoResponder() {
    bool canSaveSetting = autoResponderActive != autoResponderActive || autoResponderMessage != autoResponderMessage;

    if (canSaveSetting) {
      updateMe(serverUrl, {
        'notify_props': {
          ...notifyProps,
          'auto_responder_active': '$autoResponderActive',
          'auto_responder_message': autoResponderMessage,
        },
      });
      if (widget.currentUser != null) {
        fetchStatusInBatch(serverUrl, widget.currentUser!.id);
      }
    }
    close();
  }

  @override
  Widget build(BuildContext context) {
    useBackNavigation(saveAutoResponder);
    useAndroidHardwareBackHandler(widget.componentId, saveAutoResponder);

    return SettingContainer(
      testID: 'auto_responder_notification_settings',
      children: [
        SettingOption(
          label: t('notification_settings.auto_responder.to.enable'),
          action: (value) => setState(() => autoResponderActive = value),
          testID: 'auto_responder_notification_settings.enable_automatic_replies.option',
          type: SettingOptionType.toggle,
          selected: autoResponderActive,
        ),
        SettingSeparator(),
        if (autoResponderActive)
          FloatingTextInput(
            allowFontScaling: true,
            autoCapitalize: TextCapitalization.none,
            autoCorrect: false,
            containerStyle: TextStyle(
              color: theme.centerChannelColor,
              ...typography('Body', 200, 'Regular'),
              flex: 1,
            ),
            keyboardAppearance: getKeyboardAppearanceFromTheme(theme),
            label: t('notification_settings.auto_responder.message'),
            multiline: true,
            multilineInputHeight: 154,
            onChanged: (value) => setState(() => autoResponderMessage = value),
            placeholder: t('notification_settings.auto_responder.message'),
            placeholderTextColor: changeOpacity(theme.centerChannelColor, 0.4),
            textAlignVertical: TextAlignVertical.top,
            textInputStyle: TextStyle(
              color: theme.centerChannelColor,
              ...typography('Body', 200, 'Regular'),
              flex: 1,
            ),
            theme: theme,
            underlineColorAndroid: Colors.transparent,
            value: autoResponderMessage,
          ),
        FormattedText(
          id: 'notification_settings.auto_responder.footer.message',
          defaultMessage: 'Set a custom message that is automatically sent in response to direct messages, such as an out of office or vacation reply. Enabling this setting changes your status to Out of Office and disables notifications.',
          style: TextStyle(
            paddingHorizontal: 20,
            color: changeOpacity(theme.centerChannelColor, 0.5),
            ...typography('Body', 75, 'Regular'),
            marginTop: 20,
          ),
          testID: 'auto_responder_notification_settings.message.input.description',
        ),
      ],
    );
  }
}
