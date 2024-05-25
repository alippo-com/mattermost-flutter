// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.
import 'package:rxdart/rxdart.dart';

final Map<String, BehaviorSubject<int>> loadingTeamChannels = {};

BehaviorSubject<int> getLoadingTeamChannelsSubject(String serverUrl) {
  if (!loadingTeamChannels.containsKey(serverUrl)) {
    loadingTeamChannels[serverUrl] = BehaviorSubject.seeded(0);
  }
  return loadingTeamChannels[serverUrl];
}

void setTeamLoading(String serverUrl, bool loading) {
  final BehaviorSubject<int> subject = getLoadingTeamChannelsSubject(serverUrl);
  subject.add(subject.value + (loading ? 1 : -1));
}