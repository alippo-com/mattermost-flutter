
import 'package:flutter/material.dart';
import 'package:mattermost_flutter/actions/app/global.dart';
import 'package:mattermost_flutter/constants/general.dart';
import 'package:mattermost_flutter/constants/launch.dart';
import 'package:mattermost_flutter/queries/app/global.dart';
import 'package:mattermost_flutter/queries/app/servers.dart';
import 'package:mattermost_flutter/screens/navigation.dart';

import 'package:in_app_review/in_app_review.dart';
import 'dart:convert';

Future<void> tryRunAppReview(String launchType, {bool coldStart = false}) async {
  final LocalConfig = jsonDecode(await rootBundle.loadString('assets/config.json'));

  if (!LocalConfig['ShowReview']) {
    return;
  }

  if (!coldStart) {
    return;
  }

  if (launchType != Launch.Normal) {
    return;
  }

  if (!await InAppReview.instance.isAvailable()) {
    return;
  }

  final supported = await areAllServersSupported();
  if (!supported) {
    return;
  }

  final dontAsk = await getDontAskForReview();
  if (dontAsk) {
    return;
  }

  final lastReviewed = await getLastAskedForReview();
  if (lastReviewed != null) {
    if (DateTime.now().millisecondsSinceEpoch - lastReviewed > General.TIME_TO_NEXT_REVIEW) {
      showReviewOverlay(true);
    }
    return;
  }

  final firstLaunch = await getFirstLaunch();
  if (firstLaunch == null) {
    storeFirstLaunch();
    return;
  }

  if ((DateTime.now().millisecondsSinceEpoch - firstLaunch) > General.TIME_TO_FIRST_REVIEW) {
    showReviewOverlay(false);
  }
}
