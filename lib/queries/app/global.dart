
// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:watermelondb/watermelondb.dart';
import 'package:mattermost_flutter/constants/database.dart';
import 'package:mattermost_flutter/database/manager.dart';
import 'package:mattermost_flutter/types/database/models/app/global.dart';

class GlobalQueries {
  static const GLOBAL = MM_TABLES.APP.GLOBAL;

  Future<String> getDeviceToken() async {
    try {
      final database = DatabaseManager.getAppDatabaseAndOperator().database;
      final tokens = await database.get<GlobalModel>(GLOBAL).find(GLOBAL_IDENTIFIERS.DEVICE_TOKEN);
      return tokens?.value ?? '';
    } catch (e) {
      return '';
    }
  }

  Query<GlobalModel> queryGlobalValue(String key) {
    try {
      final database = DatabaseManager.getAppDatabaseAndOperator().database;
      return database.get<GlobalModel>(GLOBAL).query(Q.where('id', key), Q.take(1));
    } catch (e) {
      return null;
    }
  }

  Future<bool> getOnboardingViewed() async {
    try {
      final database = DatabaseManager.getAppDatabaseAndOperator().database;
      final onboardingVal = await database.get<GlobalModel>(GLOBAL).find(GLOBAL_IDENTIFIERS.ONBOARDING);
      return onboardingVal?.value ?? false;
    } catch (e) {
      return false;
    }
  }

  Future<int> getLastAskedForReview() async {
    final records = await queryGlobalValue(GLOBAL_IDENTIFIERS.LAST_ASK_FOR_REVIEW)?.fetch();
    if (records == null || records.isEmpty || records.first.value == null) {
      return 0;
    }
    return records.first.value;
  }

  Future<bool> getDontAskForReview() async {
    final records = await queryGlobalValue(GLOBAL_IDENTIFIERS.DONT_ASK_FOR_REVIEW)?.fetch();
    return records != null && records.isNotEmpty && records.first.value != null;
  }

  Future<bool> getPushDisabledInServerAcknowledged(String serverDomainString) async {
    final records = await queryGlobalValue('${GLOBAL_IDENTIFIERS.PUSH_DISABLED_ACK}$serverDomainString')?.fetch();
    return records != null && records.isNotEmpty && records.first.value != null;
  }

  Stream<bool> observePushDisabledInServerAcknowledged(String serverDomainString) {
    final query = queryGlobalValue('${GLOBAL_IDENTIFIERS.PUSH_DISABLED_ACK}$serverDomainString');
    if (query == null) {
      return Stream.value(false);
    }
    return query.observe().switchMap((result) {
      if (result.isEmpty) {
        return Stream.value(false);
      }
      return result.first.observe().switchMap((v) => Stream.value(v != null));
    });
  }

  Future<int> getFirstLaunch() async {
    final records = await queryGlobalValue(GLOBAL_IDENTIFIERS.FIRST_LAUNCH)?.fetch();
    if (records == null || records.isEmpty || records.first.value == null) {
      return 0;
    }
    return records.first.value;
  }

  Future<String> getLastViewedChannelIdAndServer() async {
    final records = await queryGlobalValue(GLOBAL_IDENTIFIERS.LAST_VIEWED_CHANNEL)?.fetch();
    return records?.first?.value;
  }

  Future<String> getLastViewedThreadIdAndServer() async {
    final records = await queryGlobalValue(GLOBAL_IDENTIFIERS.LAST_VIEWED_THREAD)?.fetch();
    return records?.first?.value;
  }

  Stream<bool> observeTutorialWatched(String tutorial) {
    final query = queryGlobalValue(tutorial);
    if (query == null) {
      return Stream.value(false);
    }
    return query.observe().switchMap((result) {
      if (result.isEmpty) {
        return Stream.value(false);
      }
      return result.first.observe().switchMap((v) => Stream.value(v != null));
    });
  }
}
