// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

class DeepLink {
  final String serverUrl;
  final String teamName;

  DeepLink({
    required this.serverUrl,
    required this.teamName,
  });
}

class DeepLinkChannel extends DeepLink {
  final String channelName;

  DeepLinkChannel({
    required String serverUrl,
    required String teamName,
    required this.channelName,
  }) : super(serverUrl: serverUrl, teamName: teamName);
}

class DeepLinkDM extends DeepLink {
  final String userName;

  DeepLinkDM({
    required String serverUrl,
    required String teamName,
    required this.userName,
  }) : super(serverUrl: serverUrl, teamName: teamName);
}

class DeepLinkPermalink extends DeepLink {
  final String postId;

  DeepLinkPermalink({
    required String serverUrl,
    required String teamName,
    required this.postId,
  }) : super(serverUrl: serverUrl, teamName: teamName);
}

class DeepLinkGM extends DeepLink {
  final String channelName;

  DeepLinkGM({
    required String serverUrl,
    required String teamName,
    required this.channelName,
  }) : super(serverUrl: serverUrl, teamName: teamName);
}

class DeepLinkPlugin extends DeepLink {
  final String id;
  final String? route;

  DeepLinkPlugin({
    required String serverUrl,
    required String teamName,
    required this.id,
    this.route,
  }) : super(serverUrl: serverUrl, teamName: teamName);
}

typedef DeepLinkType = Function();

class DeepLinkWithData {
  final DeepLinkType type;
  final String url;
  final dynamic data; // Can be any of the DeepLink types

  DeepLinkWithData({
    required this.type,
    required this.url,
    this.data,
  });
}

typedef LaunchType = Function();

class LaunchProps {
  final DeepLinkWithData? extra;
  final LaunchType launchType;
  final bool? launchError;
  final String? serverUrl;
  final String? displayName;
  final bool? coldStart;

  LaunchProps({
    this.extra,
    required this.launchType,
    this.launchError,
    this.serverUrl,
    this.displayName,
    this.coldStart,
  });
}
