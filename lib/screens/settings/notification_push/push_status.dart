import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mattermost_flutter/types.dart'; // Assuming the types are defined here
import 'package:mattermost_flutter/i18n.dart'; // Assuming the i18n functions are defined here
import 'package:mattermost_flutter/components/settings/block.dart';
import 'package:mattermost_flutter/components/settings/option.dart';
import 'package:mattermost_flutter/components/settings/separator.dart';

class MobilePushStatusProps {
  final UserNotifyPropsPushStatus pushStatus;
  final Function(UserNotifyPropsPushStatus) setMobilePushStatus;

  MobilePushStatusProps({required this.pushStatus, required this.setMobilePushStatus});
}

class MobilePushStatus extends StatelessWidget {
  final MobilePushStatusProps props;

  MobilePushStatus({required this.props});

  @override
  Widget build(BuildContext context) {
    final intl = AppLocalizations.of(context);

    return SettingBlock(
      headerText: AppLocalizations.of(context)!.notificationSettingsMobileTriggerPush,
      children: [
        SettingOption(
          action: props.setMobilePushStatus,
          label: intl.notificationSettingsMobileOnline,
          selected: props.pushStatus == UserNotifyPropsPushStatus.online,
          testID: 'push_notification_settings.mobile_online.option',
          type: 'select',
          value: UserNotifyPropsPushStatus.online,
        ),
        SettingSeparator(),
        SettingOption(
          action: props.setMobilePushStatus,
          label: intl.notificationSettingsMobileAway,
          selected: props.pushStatus == UserNotifyPropsPushStatus.away,
          testID: 'push_notification_settings.mobile_away.option',
          type: 'select',
          value: UserNotifyPropsPushStatus.away,
        ),
        SettingSeparator(),
        SettingOption(
          action: props.setMobilePushStatus,
          label: intl.notificationSettingsMobileOffline,
          selected: props.pushStatus == UserNotifyPropsPushStatus.offline,
          testID: 'push_notification_settings.mobile_offline.option',
          type: 'select',
          value: UserNotifyPropsPushStatus.offline,
        ),
        SettingSeparator(),
      ],
    );
  }
}
