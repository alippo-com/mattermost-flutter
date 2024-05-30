
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:rxdart/rxdart.dart';

import 'package:mattermost_flutter/constants/general.dart';
import 'package:mattermost_flutter/constants/permissions.dart';
import 'package:mattermost_flutter/constants/post_draft.dart';
import 'package:mattermost_flutter/queries/channel.dart';
import 'package:mattermost_flutter/queries/custom_emoji.dart';
import 'package:mattermost_flutter/queries/drafts.dart';
import 'package:mattermost_flutter/queries/role.dart';
import 'package:mattermost_flutter/queries/system.dart';
import 'package:mattermost_flutter/queries/user.dart';
import 'package:mattermost_flutter/types/database/database.dart';

import 'send_handler.dart';

const INITIAL_PRIORITY = 1;  // Adjust this based on your actual initial priority

class OwnProps {
  final String rootId;
  final String channelId;
  final bool? channelIsArchived;

  OwnProps({
    required this.rootId,
    required this.channelId,
    this.channelIsArchived,
  });
}

class SendHandlerContainer extends StatelessWidget {
  final Database database;
  final OwnProps ownProps;

  SendHandlerContainer({
    required this.database,
    required this.ownProps,
  });

  Stream<ChannelModel?> get channel {
    if (ownProps.rootId.isNotEmpty) {
      return observeChannel(database, ownProps.channelId);
    } else {
      return observeCurrentChannel(database);
    }
  }

  Stream<String> get currentUserId => observeCurrentUserId(database);

  Stream<UserModel?> get currentUser => currentUserId.switchMap((id) => observeUser(database, id));

  Stream<bool> get userIsOutOfOffice => currentUser.switchMap((u) => Stream.value(u?.status == General.OUT_OF_OFFICE));

  Stream<int> get postPriority => queryDraft(database, ownProps.channelId, ownProps.rootId)
      .map((d) => d.metadata?.priority ?? INITIAL_PRIORITY);

  Stream<bool> get enableConfirmNotificationsToChannel => observeConfigBooleanValue(database, 'EnableConfirmNotificationsToChannel');

  Stream<int> get maxMessageLength => observeConfigIntValue(database, 'MaxPostSize', MAX_MESSAGE_LENGTH_FALLBACK);

  Stream<int> get persistentNotificationInterval => observeConfigIntValue(database, 'PersistentNotificationIntervalMinutes');

  Stream<int> get persistentNotificationMaxRecipients => observeConfigIntValue(database, 'PersistentNotificationMaxRecipients');

  Stream<bool> get useChannelMentions {
    return CombineLatestStream.combine2(channel, currentUser, (ChannelModel? c, UserModel? u) {
      if (c == null) {
        return true;
      }
      return u != null ? observePermissionForChannel(database, c, u, Permissions.USE_CHANNEL_MENTIONS, false) : false;
    });
  }

  Stream<ChannelInfoModel?> get channelInfo => channel.switchMap((c) => c != null ? observeChannelInfo(database, c.id) : Stream.value(null));

  Stream<String?> get channelType => channel.map((c) => c?.type);

  Stream<String?> get channelName => channel.map((c) => c?.name);

  Stream<int> get membersCount => channelInfo.map((i) => i?.memberCount ?? 0);

  Stream<List<CustomEmojiModel>> get customEmojis => queryAllCustomEmojis(database);

  @override
  Widget build(BuildContext context) {
    return SendHandler(
      channelType: channelType,
      channelName: channelName,
      currentUserId: currentUserId,
      enableConfirmNotificationsToChannel: enableConfirmNotificationsToChannel,
      maxMessageLength: maxMessageLength,
      membersCount: membersCount,
      userIsOutOfOffice: userIsOutOfOffice,
      useChannelMentions: useChannelMentions,
      customEmojis: customEmojis,
      persistentNotificationInterval: persistentNotificationInterval,
      persistentNotificationMaxRecipients: persistentNotificationMaxRecipients,
      postPriority: postPriority,
    );
  }
}
