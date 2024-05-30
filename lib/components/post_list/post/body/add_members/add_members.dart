import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mattermost_flutter/components/formatted_text.dart';
import 'package:mattermost_flutter/constants/general.dart';
import 'package:mattermost_flutter/context/server.dart';
import 'package:mattermost_flutter/i18n.dart';
import 'package:mattermost_flutter/utils/markdown.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/actions/local/post.dart';
import 'package:mattermost_flutter/actions/remote/channel.dart';
import 'package:sqflite/sqflite.dart';

import 'package:mattermost_flutter/types/models/servers/post.dart';
import 'package:mattermost_flutter/types/models/servers/user.dart';

class AddMembers extends StatelessWidget {
  final String? channelType;
  final UserModel? currentUser;
  final String location;
  final PostModel post;
  final Theme theme;

  AddMembers({
    required this.channelType,
    this.currentUser,
    required this.location,
    required this.post,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final intl = Intl.message;
    final styles = getStyleSheet(theme);
    final textStyles = getMarkdownTextStyles(theme);
    final serverUrl = useServerUrl(context);
    final postId = post.props['add_channel_member']?['post_id'];
    final noGroupsUsernames = post.props['add_channel_member']?['not_in_groups_usernames'];
    var userIds = post.props['add_channel_member']?['not_in_channel_user_ids'];
    var usernames = post.props['add_channel_member']?['not_in_channel_usernames'];

    if (postId == null || channelType == null) {
      return Container();
    }

    if (userIds == null) {
      userIds = post.props['add_channel_member']?['user_ids'];
    }
    if (usernames == null) {
      usernames = post.props['add_channel_member']?['usernames'];
    }

    void handleAddChannelMember() {
      if (post != null && post.channelId != null && currentUser != null) {
        addMembersToChannel(serverUrl, post.channelId, userIds, post.rootId, false);
        if (post.rootId != null) {
          final messages = usernames.map((addedUsername) {
            return intl(
              'api.channel.add_member.added',
              defaultMessage: '{addedUsername} added to the channel by {username}.',
              args: {'username': currentUser.username, 'addedUsername': addedUsername},
            );
          }).toList();
          sendAddToChannelEphemeralPost(serverUrl, currentUser, usernames, messages, post.channelId, post.rootId);
        }

        removePost(serverUrl, post);
      }
    }

    List<Widget> generateAtMentions(List<String> names) {
      if (names.length == 1) {
        return [
          AtMention(
            channelId: post.channelId,
            location: location,
            mentionName: names[0],
            mentionStyle: textStyles['mention'],
          )
        ];
      } else if (names.length > 1) {
        List<Widget> mentions = [];
        for (int i = 0; i < names.length; i++) {
          mentions.add(AtMention(
            key: Key(names[i]),
            channelId: post.channelId,
            location: location,
            mentionName: names[i],
            mentionStyle: textStyles['mention'],
          ));
          if (i < names.length - 1) {
            mentions.add(Text(i < names.length - 2 ? ', ' : ' and ', style: textStyles['mention']));
          }
        }
        return mentions;
      }
      return [];
    }

    String linkId = '';
    String linkText = '';
    if (channelType == General.PRIVATE_CHANNEL) {
      linkId = t('post_body.check_for_out_of_channel_mentions.link.private');
      linkText = 'add them to this private channel';
    } else if (channelType == General.OPEN_CHANNEL) {
      linkId = t('post_body.check_for_out_of_channel_mentions.link.public');
      linkText = 'add them to the channel';
    }

    String outOfChannelMessageID = '';
    String outOfChannelMessageText = '';
    final outOfChannelAtMentions = generateAtMentions(usernames);
    if (usernames.length == 1) {
      outOfChannelMessageID = t('post_body.check_for_out_of_channel_mentions.message.one');
      outOfChannelMessageText = 'was mentioned but is not in the channel. Would you like to ';
    } else if (usernames.length > 1) {
      outOfChannelMessageID = t('post_body.check_for_out_of_channel_mentions.message.multiple');
      outOfChannelMessageText = 'were mentioned but they are not in the channel. Would you like to ';
    }

    String outOfGroupsMessageID = '';
    String outOfGroupsMessageText = '';
    final outOfGroupsAtMentions = generateAtMentions(noGroupsUsernames);
    if (noGroupsUsernames != null && noGroupsUsernames.length > 0) {
      outOfGroupsMessageID = t('post_body.check_for_out_of_channel_groups_mentions.message');
      outOfGroupsMessageText = 'did not get notified by this mention because they are not in the channel. They are also not a member of the groups linked to this channel.';
    }

    Widget outOfChannelMessage = Container();
    if (usernames.length > 0) {
      outOfChannelMessage = Text.rich(
        TextSpan(
          children: [
            ...outOfChannelAtMentions,
            TextSpan(text: ' '),
            TextSpan(
              text: intl(outOfChannelMessageID, defaultMessage: outOfChannelMessageText),
              style: styles['message'],
            ),
            TextSpan(
              text: linkText,
              style: textStyles['link'],
              recognizer: TapGestureRecognizer()..onTap = handleAddChannelMember,
            ),
            TextSpan(
              text: intl('post_body.check_for_out_of_channel_mentions.message_last', defaultMessage: '? They will have access to all message history.'),
              style: styles['message'],
            ),
          ],
        ),
      );
    }

    Widget outOfGroupsMessage = Container();
    if (noGroupsUsernames != null && noGroupsUsernames.length > 0) {
      outOfGroupsMessage = Text.rich(
        TextSpan(
          children: [
            ...outOfGroupsAtMentions,
            TextSpan(text: ' '),
            TextSpan(
              text: intl(outOfGroupsMessageID, defaultMessage: outOfGroupsMessageText),
              style: styles['message'],
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        outOfChannelMessage,
        outOfGroupsMessage,
      ],
    );
  }

  Map<String, TextStyle> getMarkdownTextStyles(Theme theme) {
    return {
      'mention': TextStyle(
        color: theme.linkColor,
        fontWeight: FontWeight.bold,
      ),
      'link': TextStyle(
        color: theme.linkColor,
      ),
    };
  }

  Map<String, dynamic> getStyleSheet(Theme theme) {
    return {
      'message': TextStyle(
        color: changeOpacity(theme.centerChannelColor, 0.6),
        fontSize: 16,
        height: 20,
      ),
    };
  }
}
