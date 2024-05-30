import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:mattermost_flutter/constants/general.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/actions/remote/channel.dart';
import 'package:mattermost_flutter/context/server.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/components/button.dart';
import 'package:mattermost_flutter/components/compass_icon.dart';
import 'package:mattermost_flutter/components/formatted_text.dart';
import 'package:mattermost_flutter/utils/tap.dart';
import 'package:mattermost_flutter/utils/typography.dart';

const double MUTED_BANNER_HEIGHT = 200;

class MutedBannerProps {
  final String channelId;

  MutedBannerProps({required this.channelId});
}

class MutedBanner extends HookWidget {
  final MutedBannerProps props;

  MutedBanner({required this.props});

  @override
  Widget build(BuildContext context) {
    final theme = useTheme(context);
    final intl = useIntl(context);
    final serverUrl = useServerUrl();
    final styles = getStyleSheet(theme);

    final onPress = useCallback(() {
      preventDoubleTap(() {
        toggleMuteChannel(serverUrl, props.channelId, false);
      });
    }, [props.channelId, serverUrl]);

    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      height: MUTED_BANNER_HEIGHT,
      decoration: styles['container'],
      child: Column(
        children: [
          Row(
            children: [
              CompassIcon(
                name: 'bell-off-outline',
                size: 24,
                color: theme.linkColor,
              ),
              FormattedText(
                id: 'channel_notification_preferences.muted_title',
                defaultMessage: 'This channel is muted',
                style: styles['title'],
              ),
            ],
          ),
          FormattedText(
            id: 'channel_notification_preferences.muted_content',
            defaultMessage:
                'You can change the notification settings, but you will not receive notifications until the channel is unmuted.',
            style: styles['contentText'],
          ),
          Button(
            buttonType: ButtonType.defaultType,
            onPress: onPress,
            text: intl.formatMessage(
              id: 'channel_notification_preferences.unmute_content',
              defaultMessage: 'Unmute channel',
            ),
            theme: theme,
            backgroundStyle: styles['button'],
            iconName: 'bell-outline',
            iconSize: 18,
          ),
        ],
      ),
    );
  }
}

Map<String, dynamic> getStyleSheet(ThemeData theme) {
  return {
    'button': BoxDecoration(
      width: '55%',
    ),
    'container': BoxDecoration(
      color: changeOpacity(theme.sidebarTextActiveBorder, 0.16),
      borderRadius: BorderRadius.circular(4),
      marginHorizontal: 20,
      marginVertical: 12,
      paddingHorizontal: 16,
      height: MUTED_BANNER_HEIGHT,
    ),
    'contentText': typography('Body', 200).copyWith(
      color: theme.centerChannelColor,
      marginTop: 12,
      marginBottom: 16,
    ),
    'titleContainer': BoxDecoration(
      alignItems: Alignment.center,
      flexDirection: Axis.horizontal,
      marginTop: 16,
    ),
    'title': typography('Heading', 200).copyWith(
      color: theme.centerChannelColor,
      marginLeft: 10,
      paddingTop: 5,
    ),
  };
}
