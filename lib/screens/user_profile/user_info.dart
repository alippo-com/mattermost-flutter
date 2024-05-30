
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mattermost_flutter/widgets/custom_status.dart';
import 'package:mattermost_flutter/widgets/label.dart';
import 'package:mattermost_flutter/types/user_model.dart';  // Assuming UserModel is defined here

class UserInfo extends StatelessWidget {
  final String? localTime;
  final bool showCustomStatus;
  final bool showLocalTime;
  final bool showNickname;
  final bool showPosition;
  final UserModel user;

  UserInfo({
    this.localTime,
    required this.showCustomStatus,
    required this.showLocalTime,
    required this.showNickname,
    required this.showPosition,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final customStatus = getUserCustomStatus(user);
    final formatMessage = (String id, {String? defaultMessage}) => Intl.message(defaultMessage ?? '', name: id);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showCustomStatus)
          UserProfileCustomStatus(customStatus: customStatus!),
        if (showNickname)
          UserProfileLabel(
            description: user.nickname,
            testID: 'user_profile.nickname',
            title: formatMessage('channel_info.nickname', defaultMessage: 'Nickname'),
          ),
        if (showPosition)
          UserProfileLabel(
            description: user.position,
            testID: 'user_profile.position',
            title: formatMessage('channel_info.position', defaultMessage: 'Position'),
          ),
        if (showLocalTime)
          UserProfileLabel(
            description: localTime!,
            testID: 'user_profile.local_time',
            title: formatMessage('channel_info.local_time', defaultMessage: 'Local Time'),
          ),
      ],
    );
  }
}
