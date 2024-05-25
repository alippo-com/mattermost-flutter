// This Dart file is auto-generated, do not edit.
// Converted from TypeScript file from Mattermost project.
// see original file for original copyrights and license information.

import 'package:mattermost_flutter/types/constants.dart';  // Adjusted import path to suit Flutter project structure

class DeepLink {
  String serverUrl;
  String teamName;

  DeepLink({required this.serverUrl, required this.teamName});
}

class DeepLinkChannel extends DeepLink {
  String channelName;

  DeepLinkChannel({required String serverUrl, required String teamName, required this.channelName})
      : super(serverUrl: serverUrl, teamName: teamName);
}

class DeepLinkDM extends DeepLink {
  String userName;

  DeepLinkDM({required String serverUrl, required String teamName, required this.userName})
      : super(serverUrl: serverUrl, teamName: teamName);
}

class DeepLinkPermalink extends DeepLink {
  String postId;

  DeepLinkPermalink({required String serverUrl, required String teamName, required this.postId})
      : super(serverUrl: serverUrl, teamName: teamName);
}

class DeepLinkGM extends DeepLink {
  String channelName;

  DeepLinkGM({required String serverUrl, required String teamName, required this.channelName})
      : super(serverUrl: serverUrl, teamName: teamName);
}

class DeepLinkPlugin extends DeepLink {
  String id;
  String? route;

  DeepLinkPlugin({required String serverUrl, required String teamName, required this.id, this.route})
      : super(serverUrl: serverUrl, teamName: teamName);
}

class DeepLinkWithData {
  String type;
  String url;
  dynamic data;

  DeepLinkWithData({required this.type, required this.url, this.data});
}

class LaunchProps {
  dynamic extra;
  String launchType;
  bool? launchError;
  String? serverUrl;
  String? displayName;
  bool? coldStart;

  LaunchProps({this.extra, required this.launchType, this.launchError, this.serverUrl, this.displayName, this.coldStart});
}