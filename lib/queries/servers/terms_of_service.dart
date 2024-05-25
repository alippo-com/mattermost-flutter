
// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:rxdart/rxdart.dart';
import 'package:mattermost_flutter/types/system.dart';
import 'package:mattermost_flutter/types/user.dart';
import 'package:mattermost_flutter/types/database.dart';

Stream<bool> observeShowToS(Database database) {
  final isLicensed = observeLicense(database).switchMap((lcs) {
    return lcs != null ? Stream.value(lcs.IsLicensed == 'true') : Stream.value(false);
  });

  final currentUser = observeCurrentUser(database);
  final customTermsOfServiceEnabled = observeConfigBooleanValue(database, 'EnableCustomTermsOfService');
  final customTermsOfServiceId = observeConfigValue(database, 'CustomTermsOfServiceId');
  final customTermsOfServicePeriod = observeConfigIntValue(database, 'CustomTermsOfServiceReAcceptancePeriod');

  final showToS = Rx.combineLatest5(
    isLicensed,
    customTermsOfServiceEnabled,
    currentUser,
    customTermsOfServiceId,
    customTermsOfServicePeriod,
    (lcs, cfg, user, id, period) {
      if (lcs == null || cfg == null) {
        return false;
      }

      if (user?.termsOfServiceId != id) {
        return true;
      }

      final timeElapsed = DateTime.now().millisecondsSinceEpoch - (user?.termsOfServiceCreateAt ?? 0);
      return timeElapsed > (period * 24 * 60 * 60 * 1000);
    },
  ).distinct();

  return showToS;
}
