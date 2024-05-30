// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:watermelondb/watermelondb.dart';
import 'package:rxdart/rxdart.dart';
import 'package:mattermost_flutter/queries/servers/user.dart';
import 'custom_status.dart';

final customStatusProvider = StreamProvider.family<CustomStatusData, String>((ref, userId) {
  final database = ref.watch(databaseProvider);
  final user = observeUser(database, userId);
  final isCustomStatusEnabled = observeConfigBooleanValue(database, 'EnableCustomUserStatuses');
  final customStatus = user.switchMap((u) => u?.isBot == true ? Stream.value(null) : Stream.value(getUserCustomStatus(u)));
  final customStatusExpired = user.switchMap((u) => u?.isBot == true ? Stream.value(false) : Stream.value(isCustomStatusExpired(u)));

  return CombineLatestStream.combine3(customStatus, customStatusExpired, isCustomStatusEnabled,
    (customStatus, customStatusExpired, isCustomStatusEnabled) => CustomStatusData(
      customStatus: customStatus,
      customStatusExpired: customStatusExpired,
      isCustomStatusEnabled: isCustomStatusEnabled,
    ));
});

class CustomStatusData {
  final dynamic customStatus;
  final bool customStatusExpired;
  final bool isCustomStatusEnabled;

  CustomStatusData({
    required this.customStatus,
    required this.customStatusExpired,
    required this.isCustomStatusEnabled,
  });
}

class CustomStatusScreen extends ConsumerWidget {
  final String userId;

  CustomStatusScreen({required this.userId});

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final customStatusAsyncValue = watch(customStatusProvider(userId));

    return customStatusAsyncValue.when(
      data: (data) {
        return CustomStatus(
          customStatus: data.customStatus,
          customStatusExpired: data.customStatusExpired,
          isCustomStatusEnabled: data.isCustomStatusEnabled,
        );
      },
      loading: () => CircularProgressIndicator(),
      error: (err, stack) => Text('Error: $err'),
    );
  }
}
