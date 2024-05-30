
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'package:mattermost_flutter/actions/remote/user.dart';
import 'package:mattermost_flutter/components/formatted_text.dart';
import 'package:mattermost_flutter/components/tag.dart';
import 'package:mattermost_flutter/constants.dart';
import 'package:mattermost_flutter/context/server.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/typography.dart';

import '../options.dart';

import 'group.dart';
import 'member.dart';

class DirectChannel extends HookWidget {
  final ChannelModel channel;
  final String currentUserId;
  final bool isBot;
  final List<ChannelMembershipModel>? members;
  final Theme theme;
  final bool hasGMasDMFeature;
  final Map<String, dynamic>? channelNotifyProps;
  final Map<String, dynamic>? userNotifyProps;

  DirectChannel({
    required this.channel,
    required this.currentUserId,
    required this.isBot,
    this.members,
    required this.theme,
    required this.hasGMasDMFeature,
    this.channelNotifyProps,
    this.userNotifyProps,
  });

  @override
  Widget build(BuildContext context) {
    final serverUrl = useServerUrl();
    final styles = _getStyleSheet(theme);

    useEffect(() {
      final channelMembers = members?.where((m) => m.userId != currentUserId).toList();
      if (channelMembers == null || channelMembers.isEmpty) {
        fetchProfilesInChannel(serverUrl, channel.id, currentUserId, false);
      }
    }, []);

    final message = useMemo(() {
      if (channel.type == General.DM_CHANNEL) {
        return FormattedText(
          defaultMessage: 'This is the start of your conversation with {teammate}. Messages and files shared here are not shown to anyone else.',
          id: 'intro.direct_message',
          style: styles['message'],
          values: {'teammate': channel.displayName},
        );
      }

      if (!hasGMasDMFeature) {
        return FormattedText(
          defaultMessage: 'This is the start of your conversation with this group. Messages and files shared here are not shown to anyone else outside of the group.',
          id: 'intro.group_message.after_gm_as_dm',
          style: styles['message'],
        );
      }

      return Text(
        style: styles['message'],
        children: [
          FormattedText(
            defaultMessage: 'This is the start of your conversation with this group.',
            id: 'intro.group_message.common',
          ),
          Text(' '),
          _getGMIntroMessageSpecificPart(userNotifyProps, channelNotifyProps, styles['boldText']),
        ],
      );
    }, [channel.displayName, theme, channelNotifyProps, userNotifyProps]);

    final profiles = useMemo(() {
      if (channel.type == General.DM_CHANNEL) {
        final teammateId = getUserIdFromChannelName(currentUserId, channel.name);
        final teammate = members?.firstWhere((m) => m.userId == teammateId, orElse: () => null);
        if (teammate == null) {
          return null;
        }

        return Member(
          channelId: channel.id,
          containerStyle: {'height': 96},
          member: teammate,
          size: 96,
          theme: theme,
        );
      }

      final channelMembers = members?.where((m) => m.userId != currentUserId).toList();
      if (channelMembers == null || channelMembers.isEmpty) {
        return null;
      }

      return Group(
        theme: theme,
        userIds: channelMembers.map((cm) => cm.userId).toList(),
      );
    }, [members, theme]);

    return Column(
      children: [
        Container(
          style: styles['profilesContainer'],
          child: profiles,
        ),
        Row(
          children: [
            Text(
              channel.displayName,
              style: styles['title'],
              key: Key('channel_post_list.intro.display_name'),
            ),
            if (isBot)
              BotTag(
                style: styles['botContainer'],
                textStyle: styles['botText'],
              ),
          ],
        ),
        message,
        IntroOptions(
          channelId: channel.id,
          header: true,
          favorite: true,
          canAddMembers: false,
        ),
      ],
    );
  }

  Map<String, dynamic> _getStyleSheet(Theme theme) {
    return {
      'botContainer': BoxDecoration(
        alignSelf: Alignment.bottomRight,
        bottom: 7.5,
        height: 20,
        marginBottom: 0,
        marginLeft: 4,
        paddingVertical: 0,
      ),
      'botText': TextStyle(
        fontSize: 14,
        lineHeight: 20,
      ),
      'container': BoxDecoration(
        alignItems: Alignment.center,
        marginHorizontal: 20.0,
      ),
      'message': TextStyle(
        color: theme.centerChannelColor,
        marginTop: 8.0,
        textAlign: TextAlign.center,
        // typography equivalent in Flutter
      ),
      'boldText': TextStyle(
        // typography equivalent in Flutter
      ),
      'profilesContainer': BoxDecoration(
        justifyContent: MainAxisAlignment.center,
        alignItems: Alignment.center,
      ),
      'title': TextStyle(
        color: theme.centerChannelColor,
        marginTop: 4.0,
        textAlign: TextAlign.center,
        // typography equivalent in Flutter
      ),
      'titleGroup': TextStyle(
        // typography equivalent in Flutter
      ),
    };
  }

  Widget _getGMIntroMessageSpecificPart(
      Map<String, dynamic>? userNotifyProps,
      Map<String, dynamic>? channelNotifyProps,
      TextStyle boldStyle) {
    final isMuted = channelNotifyProps?['mark_unread'] == 'mention';
    if (isMuted) {
      return FormattedText(
        defaultMessage: 'This group message is currently <b>muted</b>, so you will not be notified.',
        id: 'intro.group_message.muted',
        style: boldStyle,
      );
    }

    final channelNotifyProp = channelNotifyProps?['push'] ?? NotificationLevel.DEFAULT;
    final userNotifyProp = userNotifyProps?['push'] ?? NotificationLevel.MENTION;
    var notifyLevelToUse = channelNotifyProp;
    if (notifyLevelToUse == NotificationLevel.DEFAULT) {
      notifyLevelToUse = userNotifyProp;
    }
    if (channelNotifyProp == NotificationLevel.DEFAULT &&
        userNotifyProp == NotificationLevel.MENTION) {
      notifyLevelToUse = NotificationLevel.ALL;
    }

    return FormattedText(
      defaultMessage: gmIntroMessages[notifyLevelToUse],
      id: gmIntroMessages[notifyLevelToUse],
      style: boldStyle,
    );
  }
}

const gmIntroMessages = {
  'muted': 'This group message is currently <b>muted</b>, so you will not be notified.',
  NotificationLevel.ALL: 'You'll be notified <b>for all activity</b> in this group message.',
  NotificationLevel.DEFAULT: 'You'll be notified <b>for all activity</b> in this group message.',
  NotificationLevel.MENTION: 'You have selected to be notified <b>only when mentioned</b> in this group message.',
  NotificationLevel.NONE: 'You have selected to <b>never</b> be notified in this group message.',
};
