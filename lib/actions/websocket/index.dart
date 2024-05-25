
// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:mattermost_flutter/actions/local/channel.dart';
import 'package:mattermost_flutter/actions/local/systems.dart';
import 'package:mattermost_flutter/actions/remote/channel.dart';
import 'package:mattermost_flutter/actions/remote/entry/common.dart';
import 'package:mattermost_flutter/actions/remote/post.dart';
import 'package:mattermost_flutter/actions/remote/preference.dart';
import 'package:mattermost_flutter/actions/remote/user.dart';
import 'package:mattermost_flutter/calls/actions/calls.dart';
import 'package:mattermost_flutter/calls/connection/websocket_event_handlers.dart';
import 'package:mattermost_flutter/calls/utils.dart';
import 'package:mattermost_flutter/constants.dart';
import 'package:mattermost_flutter/constants/database.dart';
import 'package:mattermost_flutter/database/manager.dart';
import 'package:mattermost_flutter/managers/apps_manager.dart';
import 'package:mattermost_flutter/queries/servers/post.dart';
import 'package:mattermost_flutter/queries/servers/system.dart';
import 'package:mattermost_flutter/queries/servers/thread.dart';
import 'package:mattermost_flutter/queries/servers/user.dart';
import 'package:mattermost_flutter/store/ephemeral_store.dart';
import 'package:mattermost_flutter/store/navigation_store.dart';
import 'package:mattermost_flutter/store/team_load_store.dart';
import 'package:mattermost_flutter/utils/helpers.dart';
import 'package:mattermost_flutter/utils/log.dart';

import 'category.dart';
import 'channel.dart';
import 'group.dart';
import 'integrations.dart';
import 'posts.dart';
import 'preferences.dart';
import 'reactions.dart';
import 'roles.dart';
import 'system.dart';
import 'teams.dart';
import 'threads.dart';
import 'users.dart';

Future<void> handleFirstConnect(String serverUrl) async {
  registerDeviceToken(serverUrl);
  await autoUpdateTimezone(serverUrl);
  return doReconnect(serverUrl);
}

Future<void> handleReconnect(String serverUrl) async {
  return doReconnect(serverUrl);
}

Future<void> handleClose(String serverUrl, int lastDisconnect) async {
  final operator = DatabaseManager.serverDatabases[serverUrl]?.operator;
  if (operator == null) {
    return;
  }
  await operator.handleSystem(
    systems: [
      {
        'id': SYSTEM_IDENTIFIERS.WEBSOCKET,
        'value': lastDisconnect.toString(),
      },
    ],
    prepareRecordsOnly: false,
  );
}

Future<void> doReconnect(String serverUrl) async {
  final operator = DatabaseManager.serverDatabases[serverUrl]?.operator;
  if (operator == null) {
    throw Exception('cannot find server database');
  }

  final appDatabase = DatabaseManager.appDatabase?.database;
  if (appDatabase == null) {
    throw Exception('cannot find app database');
  }

  final database = operator.database;

  final lastDisconnectedAt = await getWebSocketLastDisconnected(database);
  await resetWebSocketLastDisconnected(operator);

  final currentTeamId = await getCurrentTeamId(database);
  final currentChannelId = await getCurrentChannelId(database);

  setTeamLoading(serverUrl, true);
  final entryData = await entry(serverUrl, currentTeamId, currentChannelId, lastDisconnectedAt);
  if (entryData.containsKey('error')) {
    setTeamLoading(serverUrl, false);
    return entryData['error'];
  }

  final models = entryData['models'];
  final initialTeamId = entryData['initialTeamId'];
  final initialChannelId = entryData['initialChannelId'];
  final prefData = entryData['prefData'];
  final teamData = entryData['teamData'];
  final chData = entryData['chData'];
  final gmConverted = entryData['gmConverted'];

  await handleEntryAfterLoadNavigation(
    serverUrl,
    teamData['memberships'] ?? [],
    chData?.memberships ?? [],
    currentTeamId ?? '',
    currentChannelId ?? '',
    initialTeamId,
    initialChannelId,
    gmConverted,
  );

  final dt = DateTime.now().millisecondsSinceEpoch;
  if (models?.isNotEmpty ?? false) {
    await operator.batchRecords(models, 'doReconnect');
  }

  final tabletDevice = isTablet();
  if (tabletDevice && initialChannelId == currentChannelId) {
    await markChannelAsRead(serverUrl, initialChannelId);
    await markChannelAsViewed(serverUrl, initialChannelId);
  }

  logInfo('WEBSOCKET RECONNECT MODELS BATCHING TOOK', '${DateTime.now().millisecondsSinceEpoch - dt}ms');
  setTeamLoading(serverUrl, false);

  await fetchPostDataIfNeeded(serverUrl);

  final currentUser = await getCurrentUser(database);
  final currentUserId = currentUser!.id;
  final currentUserLocale = currentUser.locale;
  final license = await getLicense(database);
  final config = await getConfig(database);

  if (isSupportedServerCalls(config?.version)) {
    loadConfigAndCalls(serverUrl, currentUserId);
  }

  await deferredAppEntryActions(
    serverUrl,
    lastDisconnectedAt,
    currentUserId,
    currentUserLocale,
    prefData.preferences,
    config,
    license,
    teamData,
    chData,
    initialTeamId,
  );

  openAllUnreadChannels(serverUrl);

  await dataRetentionCleanup(serverUrl);

  await AppsManager.refreshAppBindings(serverUrl);
}

Future<void> handleEvent(String serverUrl, Map<String, dynamic> msg) async {
  switch (msg['event']) {
    case WebsocketEvents.POSTED:
    case WebsocketEvents.EPHEMERAL_MESSAGE:
      await handleNewPostEvent(serverUrl, msg);
      break;
    case WebsocketEvents.POST_EDITED:
      await handlePostEdited(serverUrl, msg);
      break;
    case WebsocketEvents.POST_DELETED:
      await handlePostDeleted(serverUrl, msg);
      break;
    case WebsocketEvents.POST_UNREAD:
      await handlePostUnread(serverUrl, msg);
      break;
    case WebsocketEvents.POST_ACKNOWLEDGEMENT_ADDED:
      await handlePostAcknowledgementAdded(serverUrl, msg);
      break;
    case WebsocketEvents.POST_ACKNOWLEDGEMENT_REMOVED:
      await handlePostAcknowledgementRemoved(serverUrl, msg);
      break;
    case WebsocketEvents.LEAVE_TEAM:
      await handleLeaveTeamEvent(serverUrl, msg);
      break;
    case WebsocketEvents.UPDATE_TEAM:
      await handleUpdateTeamEvent(serverUrl, msg);
      break;
    case WebsocketEvents.ADDED_TO_TEAM:
      await handleUserAddedToTeamEvent(serverUrl, msg);
      break;
    case WebsocketEvents.USER_ADDED:
      await handleUserAddedToChannelEvent(serverUrl, msg);
      break;
    case WebsocketEvents.USER_REMOVED:
      await handleUserRemovedFromChannelEvent(serverUrl, msg);
      break;
    case WebsocketEvents.USER_UPDATED:
      await handleUserUpdatedEvent(serverUrl, msg);
      break;
    case WebsocketEvents.ROLE_UPDATED:
      await handleRoleUpdatedEvent(serverUrl, msg);
      break;
    case WebsocketEvents.USER_ROLE_UPDATED:
      await handleUserRoleUpdatedEvent(serverUrl, msg);
      break;
    case WebsocketEvents.MEMBERROLE_UPDATED:
      await handleTeamMemberRoleUpdatedEvent(serverUrl, msg);
      break;
    case WebsocketEvents.CATEGORY_CREATED:
      await handleCategoryCreatedEvent(serverUrl, msg);
      break;
    case WebsocketEvents.CATEGORY_UPDATED:
      await handleCategoryUpdatedEvent(serverUrl, msg);
      break;
    case WebsocketEvents.CATEGORY_ORDER_UPDATED:
      await handleCategoryOrderUpdatedEvent(serverUrl, msg);
      break;
    case WebsocketEvents.CATEGORY_DELETED:
      await handleCategoryDeletedEvent(serverUrl, msg);
      break;
    case WebsocketEvents.CHANNEL_CREATED:
      await handleChannelCreatedEvent(serverUrl, msg);
      break;
    case WebsocketEvents.CHANNEL_DELETED:
      await handleChannelDeletedEvent(serverUrl, msg);
      break;
    case WebsocketEvents.CHANNEL_UNARCHIVED:
      await handleChannelUnarchiveEvent(serverUrl, msg);
      break;
    case WebsocketEvents.CHANNEL_UPDATED:
      await handleChannelUpdatedEvent(serverUrl, msg);
      break;
    case WebsocketEvents.CHANNEL_CONVERTED:
      await handleChannelConvertedEvent(serverUrl, msg);
      break;
    case WebsocketEvents.CHANNEL_VIEWED:
      await handleChannelViewedEvent(serverUrl, msg);
      break;
    case WebsocketEvents.MULTIPLE_CHANNELS_VIEWED:
      await handleMultipleChannelsViewedEvent(serverUrl, msg);
      break;
    case WebsocketEvents.CHANNEL_MEMBER_UPDATED:
      await handleChannelMemberUpdatedEvent(serverUrl, msg);
      break;
    case WebsocketEvents.CHANNEL_SCHEME_UPDATED:
      // Do nothing, handled by CHANNEL_UPDATED due to changes in the channel scheme.
      break;
    case WebsocketEvents.DIRECT_ADDED:
    case WebsocketEvents.GROUP_ADDED:
      await handleDirectAddedEvent(serverUrl, msg);
      break;
    case WebsocketEvents.PREFERENCE_CHANGED:
      await handlePreferenceChangedEvent(serverUrl, msg);
      break;
    case WebsocketEvents.PREFERENCES_CHANGED:
      await handlePreferencesChangedEvent(serverUrl, msg);
      break;
    case WebsocketEvents.PREFERENCES_DELETED:
      await handlePreferencesDeletedEvent(serverUrl, msg);
      break;
    case WebsocketEvents.STATUS_CHANGED:
      await handleStatusChangedEvent(serverUrl, msg);
      break;
    case WebsocketEvents.TYPING:
      await handleUserTypingEvent(serverUrl, msg);
      break;
    case WebsocketEvents.REACTION_ADDED:
      await handleReactionAddedToPostEvent(serverUrl, msg);
      break;
    case WebsocketEvents.REACTION_REMOVED:
      await handleReactionRemovedFromPostEvent(serverUrl, msg);
      break;
    case WebsocketEvents.EMOJI_ADDED:
      await handleAddCustomEmoji(serverUrl, msg);
      break;
    case WebsocketEvents.LICENSE_CHANGED:
      await handleLicenseChangedEvent(serverUrl, msg);
      break;
    case WebsocketEvents.CONFIG_CHANGED:
      await handleConfigChangedEvent(serverUrl, msg);
      break;
    case WebsocketEvents.OPEN_DIALOG:
      await handleOpenDialogEvent(serverUrl, msg);
      break;
    case WebsocketEvents.DELETE_TEAM:
      await handleTeamArchived(serverUrl, msg);
      break;
    case WebsocketEvents.RESTORE_TEAM:
      await handleTeamRestored(serverUrl, msg);
      break;
    case WebsocketEvents.THREAD_UPDATED:
      await handleThreadUpdatedEvent(serverUrl, msg);
      break;
    case WebsocketEvents.THREAD_READ_CHANGED:
      await handleThreadReadChangedEvent(serverUrl, msg);
      break;
    case WebsocketEvents.THREAD_FOLLOW_CHANGED:
      await handleThreadFollowChangedEvent(serverUrl, msg);
      break;
    case WebsocketEvents.APPS_FRAMEWORK_REFRESH_BINDINGS:
      break;

      // return dispatch(handleRefreshAppsBindings());

    // Calls ws events:
    case WebsocketEvents.CALLS_CHANNEL_ENABLED:
      await handleCallChannelEnabled(serverUrl, msg);
      break;
    case WebsocketEvents.CALLS_CHANNEL_DISABLED:
      await handleCallChannelDisabled(serverUrl, msg);
      break;

    // DEPRECATED in favour of user_joined (since v0.21.0)
    case WebsocketEvents.CALLS_USER_CONNECTED:
      await handleCallUserConnected(serverUrl, msg);
      break;

    // DEPRECATED in favour of user_left (since v0.21.0)
    case WebsocketEvents.CALLS_USER_DISCONNECTED:
      await handleCallUserDisconnected(serverUrl, msg);
      break;

    case WebsocketEvents.CALLS_USER_JOINED:
      await handleCallUserJoined(serverUrl, msg);
      break;
    case WebsocketEvents.CALLS_USER_LEFT:
      await handleCallUserLeft(serverUrl, msg);
      break;
    case WebsocketEvents.CALLS_USER_MUTED:
      await handleCallUserMuted(serverUrl, msg);
      break;
    case WebsocketEvents.CALLS_USER_UNMUTED:
      await handleCallUserUnmuted(serverUrl, msg);
      break;
    case WebsocketEvents.CALLS_USER_VOICE_ON:
      await handleCallUserVoiceOn(msg);
      break;
    case WebsocketEvents.CALLS_USER_VOICE_OFF:
      await handleCallUserVoiceOff(msg);
      break;
    case WebsocketEvents.CALLS_CALL_START:
      await handleCallStarted(serverUrl, msg);
      break;
    case WebsocketEvents.CALLS_SCREEN_ON:
      await handleCallScreenOn(serverUrl, msg);
      break;
    case WebsocketEvents.CALLS_SCREEN_OFF:
      await handleCallScreenOff(serverUrl, msg);
      break;
    case WebsocketEvents.CALLS_USER_RAISE_HAND:
      await handleCallUserRaiseHand(serverUrl, msg);
      break;
    case WebsocketEvents.CALLS_USER_UNRAISE_HAND:
      await handleCallUserUnraiseHand(serverUrl, msg);
      break;
    case WebsocketEvents.CALLS_CALL_END:
      await handleCallEnded(serverUrl, msg);
      break;
    case WebsocketEvents.CALLS_USER_REACTED:
      await handleCallUserReacted(serverUrl, msg);
      break;

    // DEPRECATED in favour of CALLS_JOB_STATE (since v2.15.0)
    case WebsocketEvents.CALLS_RECORDING_STATE:
      await handleCallRecordingState(serverUrl, msg);
      break;
    case WebsocketEvents.CALLS_JOB_STATE:
      await handleCallJobState(serverUrl, msg);
      break;
    case WebsocketEvents.CALLS_HOST_CHANGED:
      await handleCallHostChanged(serverUrl, msg);
      break;
    case WebsocketEvents.CALLS_USER_DISMISSED_NOTIFICATION:
      await handleUserDismissedNotification(serverUrl, msg);
      break;
    case WebsocketEvents.CALLS_CAPTION:
      await handleCallCaption(serverUrl, msg);
      break;

    case WebsocketEvents.GROUP_RECEIVED:
      await handleGroupReceivedEvent(serverUrl, msg);
      break;
    case WebsocketEvents.GROUP_MEMBER_ADD:
      await handleGroupMemberAddEvent(serverUrl, msg);
      break;
    case WebsocketEvents.GROUP_MEMBER_DELETE:
      await handleGroupMemberDeleteEvent(serverUrl, msg);
      break;
    case WebsocketEvents.GROUP_ASSOCIATED_TO_TEAM:
      await handleGroupTeamAssociatedEvent(serverUrl, msg);
      break;
    case WebsocketEvents.GROUP_DISSOCIATED_TO_TEAM:
      await handleGroupTeamDissociateEvent(serverUrl, msg);
      break;
    case WebsocketEvents.GROUP_ASSOCIATED_TO_CHANNEL:
      break;
    case WebsocketEvents.GROUP_DISSOCIATED_TO_CHANNEL:
      break;

    // Plugins
    case WebsocketEvents.PLUGIN_STATUSES_CHANGED:
    case WebsocketEvents.PLUGIN_ENABLED:
    case WebsocketEvents.PLUGIN_DISABLED:
      // Do nothing, this event doesn't need logic in the mobile app
      break;
  }
}

Future<void> fetchPostDataIfNeeded(String serverUrl) async {
  try {
    final serverDatabase = DatabaseManager.getServerDatabaseAndOperator(serverUrl);
    final database = serverDatabase.database;
    final currentChannelId = await getCurrentChannelId(database);
    final isCRTEnabled = await getIsCRTEnabled(database);
    final mountedScreens = NavigationStore.getScreensInStack();
    final isChannelScreenMounted = mountedScreens.contains(Screens.CHANNEL);
    final isThreadScreenMounted = mountedScreens.contains(Screens.THREAD);
    final tabletDevice = isTablet();

    if (isCRTEnabled && isThreadScreenMounted) {
      // Fetch new posts in the thread only when CRT is enabled,
      // for non-CRT fetchPostsForChannel includes posts in the thread
      final rootId = EphemeralStore.getCurrentThreadId();
      if (rootId != null) {
        final lastPost = await getLastPostInThread(database, rootId);
        if (lastPost != null) {
          final options = FetchPaginatedThreadOptions(
            fromCreateAt: lastPost.createAt,
            fromPost: lastPost.id,
            direction: 'down',
          );
          await fetchPostThread(serverUrl, rootId, options);
        }
      }
    }

    if (currentChannelId != null && (isChannelScreenMounted || tabletDevice)) {
      await fetchPostsForChannel(serverUrl, currentChannelId);
      await markChannelAsRead(serverUrl, currentChannelId);
      if (!EphemeralStore.wasNotificationTapped()) {
        await markChannelAsViewed(serverUrl, currentChannelId, true);
      }
      EphemeralStore.setNotificationTapped(false);
    }
  } catch (error) {
    logDebug('could not fetch needed post after WS reconnect', error);
  }
}
