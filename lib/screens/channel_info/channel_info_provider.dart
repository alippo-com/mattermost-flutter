
// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mattermost_flutter/components/channel_info/channel_info.dart';
import 'package:mattermost_flutter/hooks/observe.dart';
import 'package:mattermost_flutter/utils/channel.dart';
import 'package:mattermost_flutter/utils/helpers.dart';
import 'package:mattermost_flutter/utils/user.dart';
import 'package:mattermost_flutter/queries/servers/channel.dart';
import 'package:mattermost_flutter/queries/servers/role.dart';
import 'package:mattermost_flutter/queries/servers/system.dart';
import 'package:mattermost_flutter/queries/servers/thread.dart';
import 'package:mattermost_flutter/queries/servers/user.dart';
import 'package:mattermost_flutter/context/server.dart';
import 'package:mattermost_flutter/types/database/database.dart';

class ChannelInfoProvider extends HookWidget {
  final String serverUrl;

  ChannelInfoProvider({required this.serverUrl});

  @override
  Widget build(BuildContext context) {
    final database = useProvider(databaseProvider);
    final currentUser = observeCurrentUser(database);
    final channel = observeCurrentChannel(database);
    final type = useStream(channel.map((c) => c?.type)).data;
    final channelId = useStream(channel.map((c) => c?.id ?? '')).data;
    final teamId = useStream(channel.switchMap((c) => c?.teamId != null ? Stream.value(c.teamId) : observeCurrentTeamId(database))).data;
    final userId = observeCurrentUserId(database);
    final isTeamAdmin = useStream(combineLatest(teamId, userId).switchMap((values) => observeUserIsTeamAdmin(database, values[1], values[0]))).data;

    // callsDefaultEnabled means "live mode" post 7.6
    final callsDefaultEnabled = useStream(observeCallsConfig(serverUrl).map((config) => config.DefaultEnabled)).data;
    final allowEnableCalls = useStream(observeCallsConfig(serverUrl).map((config) => config.AllowEnableCalls)).data;
    final systemAdmin = useStream(currentUser.map((u) => u != null ? isSystemAdmin(u.roles ?? '') : false)).data;
    final channelAdmin = useStream(combineLatest(userId, channelId).switchMap((values) => observeUserIsChannelAdmin(database, values[0], values[1]))).data;
    final callsGAServer = useStream(observeConfigValue(database, 'Version').map((v) => isMinimumServerVersion(v ?? '', 7, 6))).data;
    final dmOrGM = useStream(Stream.value(type).map((t) => isTypeDMorGM(t))).data;

    final canEnableDisableCalls = useStream(
      combineLatest([callsDefaultEnabled, allowEnableCalls, systemAdmin, channelAdmin, callsGAServer, dmOrGM, isTeamAdmin]).switchMap((values) {
        final liveMode = values[0];
        final allow = values[1];
        final sysAdmin = values[2];
        final chAdmin = values[3];
        final gaServer = values[4];
        final dmGM = values[5];
        final tAdmin = values[6];

        if (gaServer) {
          if (allow && !liveMode) {
            return Stream.value(sysAdmin);
          }
          if (allow && liveMode) {
            return Stream.value(chAdmin || tAdmin || sysAdmin || dmGM);
          }
          return Stream.value(false);
        }

        if (allow && liveMode) {
          return Stream.value(chAdmin || sysAdmin || dmGM);
        }
        if (allow && !liveMode) {
          return Stream.value(sysAdmin || chAdmin || dmGM);
        }
        if (!allow) {
          return Stream.value(sysAdmin);
        }
        return Stream.value(false);
      }),
    ).data;

    final isCallsEnabledInChannel = observeIsCallsEnabledInChannel(database, serverUrl, observeCurrentChannelId(database));
    final canManageMembers = useStream(currentUser.combineLatestWith(channelId).switchMap((values) => observeCanManageChannelMembers(database, values[1], values[0]))).data;
    final canManageSettings = useStream(currentUser.combineLatestWith(channelId).switchMap((values) => observeCanManageChannelSettings(database, values[1], values[0]))).data;
    final isGuestUser = useStream(currentUser.map((u) => u?.isGuest ?? false)).data;
    final isConvertGMFeatureAvailable = useStream(observeConfigValue(database, 'Version').map((version) => isMinimumServerVersion(version ?? '', 9, 1))).data;

    return ChannelInfo(
      type: type,
      canEnableDisableCalls: canEnableDisableCalls,
      isCallsEnabledInChannel: isCallsEnabledInChannel,
      canManageMembers: canManageMembers,
      isCRTEnabled: observeIsCRTEnabled(database),
      canManageSettings: canManageSettings,
      isGuestUser: isGuestUser,
      isConvertGMFeatureAvailable: isConvertGMFeatureAvailable,
    );
  }
}
