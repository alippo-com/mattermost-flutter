
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:mattermost_flutter/components/formatted_relative_time.dart';
import 'package:mattermost_flutter/components/user_item.dart';
import 'package:mattermost_flutter/constants.dart';
import 'package:mattermost_flutter/screens/navigation.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/types.dart';

const double USER_ROW_HEIGHT = 60;

class UserListItem extends StatelessWidget {
  final String channelId;
  final String location;
  final UserModel user;
  final int userAcknowledgement;
  final UserTimezone? timezone;

  UserListItem({
    required this.channelId,
    required this.location,
    required this.user,
    required this.userAcknowledgement,
    this.timezone,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = getStyleSheet(theme);

    return UserItem(
      footerComponent: FormattedRelativeTime(
        value: userAcknowledgement,
        timezone: timezone,
        style: style['time'],
      ),
      containerStyle: style['container'],
      onUserPress: (userProfile) => handleUserPress(userProfile, theme),
      size: 40,
      user: user,
    );
  }

  Map<String, dynamic> getStyleSheet(ThemeData theme) {
    return {
      'container': BoxDecoration(
        // Flutter BoxDecoration for container styling
        border: Border.all(color: Colors.transparent),
        borderRadius: BorderRadius.circular(4.0),
      ),
      'pictureContainer': BoxDecoration(
        // Flutter BoxDecoration for picture container
        border: Border.all(color: Colors.transparent),
        borderRadius: BorderRadius.circular(4.0),
      ),
      'time': TextStyle(
        color: changeOpacity(theme.colorScheme.onBackground, 0.64),
        ...typography('Body', 75),
      ),
    };
  }

  void handleUserPress(UserProfile userProfile, ThemeData theme) async {
    if (userProfile != null) {
      await dismissBottomSheet(Screens.BOTTOM_SHEET);
      final screen = Screens.USER_PROFILE;
      final title = Intl.message('Profile', name: 'mobile.routes.user_profile');
      final closeButtonId = 'close-user-profile';
      final props = {
        'closeButtonId': closeButtonId,
        'location': location,
        'userId': userProfile.id,
        'channelId': channelId
      };

      SystemChannels.textInput.invokeMethod('TextInput.hide');
      openAsBottomSheet(screen: screen, title: title, theme: theme, closeButtonId: closeButtonId, props: props);
    }
  }
}
