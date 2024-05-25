// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.
import 'dart:async';

Map<String, StreamController<int>> loadingTeamChannels = {};

StreamController<int> getLoadingTeamChannelsSubject(String serverUrl) {
  if (!loadingTeamChannels.containsKey(serverUrl)) {
    loadingTeamChannels[serverUrl] = StreamController<int>.broadcast();
  }
  return loadingTeamChannels[serverUrl];
}

void setTeamLoading(String serverUrl, bool loading) {
  final subject = getLoadingTeamChannelsSubject(serverUrl);
  subject.add(subject.stream.value + (loading ? 1 : -1));
}