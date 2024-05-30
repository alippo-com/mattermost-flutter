
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'package:mattermost_flutter/actions/remote/channel.dart';
import 'package:mattermost_flutter/components/compass_icon.dart';
import 'package:mattermost_flutter/components/formatted_text.dart';
import 'package:mattermost_flutter/components/option_box.dart';
import 'package:mattermost_flutter/constants/events.dart';
import 'package:mattermost_flutter/context/server.dart';
import 'package:mattermost_flutter/context/theme.dart';

class UserProfileOptions extends HookWidget {
  final String location;
  final String type;
  final String userId;
  final String username;

  UserProfileOptions({required this.location, required this.type, required this.userId, required this.username});

  @override
  Widget build(BuildContext context) {
    final intl = useIntl(); // Assuming a similar intl package exists in Dart
    final theme = useTheme();
    final serverUrl = useServerUrl();

    final buttonStyle = useMemo(() {
      return buttonBackgroundStyle(theme, 'lg', 'tertiary', 'default');
    }, [theme]);

    final mentionUser = useCallback(() async {
      await dismissBottomSheet(Screens.USER_PROFILE);
      DeviceEventEmitter.emit(Events.SEND_TO_POST_DRAFT, {'location': location, 'text': '@$username'});
    }, [location, username]);

    final openChannel = useCallback(() async {
      await dismissBottomSheet(Screens.USER_PROFILE);
      final data = await createDirectChannel(serverUrl, userId);
      if (data != null) {
        switchToChannelById(serverUrl, data.id);
      }
    }, [userId, serverUrl]);

    if (type == 'all') {
      return Container(
        decoration: containerStyle,
        child: Row(
          children: [
            OptionBox(
              iconName: 'send',
              onPress: openChannel,
              testID: 'user_profile_options.send_message.option',
              text: intl.formatMessage(id: 'channel_info.send_mesasge', defaultMessage: 'Send message'),
            ),
            Container(decoration: dividerStyle),
            OptionBox(
              iconName: 'at',
              onPress: mentionUser,
              testID: 'user_profile_options.mention.option',
              text: intl.formatMessage(id: 'channel_info.mention', defaultMessage: 'Mention'),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: singleContainerStyle,
      child: GestureDetector(
        onTap: openChannel,
        child: Row(
          children: [
            CompassIcon(
              color: theme.buttonBg,
              name: 'send',
              style: iconStyle,
            ),
            FormattedText(
              id: 'channel_info.send_a_mesasge',
              defaultMessage: 'Send a message',
              style: buttonTextStyle(theme, 'lg', 'tertiary', 'default').merge(TextStyle(marginLeft: 8)),
            ),
          ],
        ),
      ),
    );
  }
}
