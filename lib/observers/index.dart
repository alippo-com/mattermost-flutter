// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:rxdart/rxdart.dart';
import 'package:mattermost_flutter/state/calls.dart';
import 'package:mattermost_flutter/utils/calls.dart';
import 'package:mattermost_flutter/constants.dart';
import 'package:mattermost_flutter/database/manager.dart';
import 'package:mattermost_flutter/queries/servers/user.dart';

class LimitRestrictedInfo {
  final bool limitRestricted;
  final int maxParticipants;
  final bool isCloudStarter;

  LimitRestrictedInfo({
    required this.limitRestricted,
    required this.maxParticipants,
    required this.isCloudStarter,
  });
}

Stream<bool> observeIsCallsEnabledInChannel(Database database, String serverUrl, Stream<String> channelId) {
  final callsDefaultEnabled = observeCallsConfig(serverUrl)
      .switchMap((config) => Stream.value(config.DefaultEnabled))
      .distinctUntilChanged();

  final callsStateEnabledDict = observeCallsState(serverUrl)
      .switchMap((state) => Stream.value(state.enabled))
      .distinctUntilChanged();

  final callsGAServer = observeConfigValue(database, 'Version')
      .switchMap((v) => Stream.value(isMinimumServerVersion(v ?? '', 7, 6)));

  return Rx.combineLatest4(
    channelId,
    callsStateEnabledDict,
    callsDefaultEnabled,
    callsGAServer,
    (id, enabled, defaultEnabled, gaServer) {
      final explicitlyEnabled = enabled.containsKey(id) && enabled[id];
      final explicitlyDisabled = enabled.containsKey(id) && !enabled[id];
      return explicitlyEnabled || (!explicitlyDisabled && defaultEnabled) || (!explicitlyDisabled && gaServer);
    },
  ).distinctUntilChanged();
}

Stream<LimitRestrictedInfo> observeIsCallLimitRestricted(Database database, String serverUrl, String channelId) {
  final maxParticipants = observeCallsConfig(serverUrl)
      .switchMap((c) => Stream.value(c.MaxCallParticipants))
      .distinctUntilChanged();

  final callNumOfParticipants = observeCallsState(serverUrl)
      .switchMap((cs) => Stream.value(cs.calls[channelId]?.sessions?.length ?? 0))
      .distinctUntilChanged();

  final isCloud = observeLicense(database)
      .switchMap((l) => Stream.value(l?.Cloud == 'true'))
      .distinctUntilChanged();

  final skuShortName = observeCallsConfig(serverUrl)
      .switchMap((c) => Stream.value(c.sku_short_name))
      .distinctUntilChanged();

  return Rx.combineLatest4(
    maxParticipants,
    callNumOfParticipants,
    isCloud,
    skuShortName,
    (max, numParticipants, cloud, sku) => LimitRestrictedInfo(
      limitRestricted: max != 0 && numParticipants >= max,
      maxParticipants: max,
      isCloudStarter: cloud && sku == License.SKU_SHORT_NAME.Starter,
    ),
  ).distinctUntilChanged((prev, curr) =>
      prev.limitRestricted == curr.limitRestricted &&
      prev.maxParticipants == curr.maxParticipants &&
      prev.isCloudStarter == curr.isCloudStarter);
}

Stream<Database?> observeCallDatabase() {
  final currentCall = observeCurrentCall();
  return currentCall
      .switchMap((call) => Stream.value(call?.serverUrl))
      .distinctUntilChanged()
      .switchMap((url) => Stream.value(DatabaseManager.serverDatabases[url]?.database));
}

Stream<Map<String, UserModel>> observeCurrentSessionsDict() {
  final currentCall = observeCurrentCall();
  final database = observeCallDatabase();

  return Rx.combineLatest2(
    database,
    currentCall,
    (db, call) => db != null && call != null
        ? queryUsersById(db, userIds(call.sessions.values.toList()))
            .observeWithColumns(['nickname', 'username', 'first_name', 'last_name', 'last_picture_update'])
            .switchMap((ps) => Stream.value(fillUserModels(call.sessions, ps)))
        : Stream.value(<String, UserModel>{}),
  );
}

Map<String, Stream<bool>> observeCallStateInChannel(String serverUrl, Database database, Stream<String> channelId) {
  final isCallInCurrentChannel = Rx.combineLatest2(
    channelId,
    observeChannelsWithCalls(serverUrl),
    (id, calls) => calls.containsKey(id),
  ).distinctUntilChanged();

  final currentCall = observeCurrentCall();

  final ccChannelId = currentCall
      .switchMap((call) => Stream.value(call?.channelId))
      .distinctUntilChanged();

  final isInACall = currentCall
      .switchMap((call) => Stream.value(call?.connected == true))
      .distinctUntilChanged();

  final dismissed = Rx.combineLatest2(
    channelId,
    observeCallsState(serverUrl),
    (id, state) => state.calls[id]?.dismissed[state.myUserId] == true,
  ).distinctUntilChanged();

  final isInCurrentChannelCall = Rx.combineLatest2(
    channelId,
    ccChannelId,
    (id, ccId) => id == ccId,
  ).distinctUntilChanged();

  final showJoinCallBanner = Rx.combineLatest3(
    isCallInCurrentChannel,
    dismissed,
    isInCurrentChannelCall,
    (isCall, dism, inCurrCall) => isCall && !dism && !inCurrCall,
  ).distinctUntilChanged();

  final showIncomingCalls = observeIncomingCalls()
      .switchMap((ics) => Stream.value(ics.incomingCalls.isNotEmpty))
      .distinctUntilChanged();

  return {
    'showJoinCallBanner': showJoinCallBanner,
    'isInACall': isInACall,
    'showIncomingCalls': showIncomingCalls,
  };
}
