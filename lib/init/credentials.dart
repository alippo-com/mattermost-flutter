// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mattermost_flutter/types/database/manager.dart';
import 'package:mattermost_flutter/types/managers/analytics.dart';
import 'package:mattermost_flutter/types/utils/log.dart';
import 'package:mattermost_flutter/types/utils/mattermost_managed.dart';

class ServerCredential {
  final String serverUrl;
  final String userId;
  final String token;

  ServerCredential({
    required this.serverUrl,
    required this.userId,
    required this.token,
  });
}

final _storage = FlutterSecureStorage();

Future<List<ServerCredential>> getAllServerCredentials() async {
  final List<ServerCredential> serverCredentials = [];

  List<String> serverUrls;
  if (Platform.isIOS) {
    serverUrls = await _storage.readAll().then((data) => data.keys.toList());
  } else {
    serverUrls = await _storage.readAll().then((data) => data.keys.toList());
  }

  for (var serverUrl in serverUrls) {
    final serverCredential = await getServerCredentials(serverUrl);
    if (serverCredential != null) {
      serverCredentials.add(serverCredential);
    }
  }

  return serverCredentials;
}

Future<String?> getActiveServerUrl() async {
  var serverUrl = await DatabaseManager.getActiveServerUrl();
  if (serverUrl == null) {
    List<String> serverUrls;
    if (Platform.isIOS) {
      serverUrls = await _storage.readAll().then((data) => data.keys.toList());
    } else {
      serverUrls = await _storage.readAll().then((data) => data.keys.toList());
    }
    serverUrl = serverUrls.isNotEmpty ? serverUrls[0] : null;
  }
  return serverUrl;
}

void setServerCredentials(String serverUrl, String token) {
  if (serverUrl.isEmpty || token.isEmpty) {
    return;
  }

  try {
    _storage.write(key: serverUrl, value: token);
  } catch (e) {
    logWarning('could not set credentials', e.toString());
  }
}

Future<void> removeServerCredentials(String serverUrl) async {
  await _storage.delete(key: serverUrl);
}

Future<void> removeActiveServerCredentials() async {
  final serverUrl = await getActiveServerUrl();
  if (serverUrl != null) {
    await removeServerCredentials(serverUrl);
  }
}

Future<ServerCredential?> getServerCredentials(String serverUrl) async {
  try {
    final token = await _storage.read(key: serverUrl);
    if (token != null && token != 'undefined') {
      final userId = ''; // Placeholder, as the original TypeScript code splits username to get userId

      final analyticsClient = Analytics.get(serverUrl);
      analyticsClient?.setUserId(userId);

      return ServerCredential(serverUrl: serverUrl, userId: userId, token: token);
    }
    return null;
  } catch (e) {
    return null;
  }
}
