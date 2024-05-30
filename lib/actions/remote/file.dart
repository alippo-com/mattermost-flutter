// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:mattermost_flutter/constants/network.dart';
import 'package:mattermost_flutter/utils/errors.dart';
import 'package:mattermost_flutter/utils/log.dart';
import 'package:mattermost_flutter/types/client.dart';
import 'package:mattermost_flutter/types/client_response.dart';
import 'package:mattermost_flutter/types/client_response_error.dart';

Future<void> downloadFile(String serverUrl, String fileId, String destination) async {
  final client = NetworkManager.getClient(serverUrl);
  await client.apiClient.download(client.getFileRoute(fileId), destination.replaceFirst('file://', ''), timeoutInterval: DOWNLOAD_TIMEOUT);
}

Future<void> downloadProfileImage(String serverUrl, String userId, int lastPictureUpdate, String destination) async {
  final client = NetworkManager.getClient(serverUrl);
  await client.apiClient.download(client.getProfilePictureUrl(userId, lastPictureUpdate), destination.replaceFirst('file://', ''), timeoutInterval: DOWNLOAD_TIMEOUT);
}

Future<Map<String, dynamic>> uploadFile(
  String serverUrl,
  FileInfo file,
  String channelId,
  void Function(double fractionCompleted, [int? bytesRead]) onProgress = _doNothing,
  void Function(ClientResponse response) onComplete = _doNothing,
  void Function(ClientResponseError response) onError = _doNothing,
  int skipBytes = 0,
) async {
  try {
    final client = NetworkManager.getClient(serverUrl);
    return {'cancel': client.uploadPostAttachment(file, channelId, onProgress, onComplete, onError, skipBytes)};
  } catch (error) {
    logDebug('Error on uploadFile', getFullErrorMessage(error));
    return {'error': error};
  }
}

Future<dynamic> fetchPublicLink(String serverUrl, String fileId) async {
  try {
    final client = NetworkManager.getClient(serverUrl);
    final publicLink = await client.getFilePublicLink(fileId);
    return publicLink;
  } catch (error) {
    logDebug('Error on fetchPublicLink', getFullErrorMessage(error));
    forceLogoutIfNecessary(serverUrl, error);
    return {'error': error};
  }
}

String buildFileUrl(String serverUrl, String fileId, [int timestamp = 0]) {
  Client? client;
  try {
    client = NetworkManager.getClient(serverUrl);
  } catch (error) {
    return '';
  }
  return client.getFileUrl(fileId, timestamp);
}

String buildAbsoluteUrl(String serverUrl, String relativePath) {
  Client? client;
  try {
    client = NetworkManager.getClient(serverUrl);
  } catch (error) {
    return '';
  }
  return client.getAbsoluteUrl(relativePath);
}

String buildFilePreviewUrl(String serverUrl, String fileId, [int timestamp = 0]) {
  Client? client;
  try {
    client = NetworkManager.getClient(serverUrl);
  } catch (error) {
    return '';
  }
  return client.getFilePreviewUrl(fileId, timestamp);
}

String buildFileThumbnailUrl(String serverUrl, String fileId, [int timestamp = 0]) {
  Client? client;
  try {
    client = NetworkManager.getClient(serverUrl);
  } catch (error) {
    return '';
  }
  return client.getFileThumbnailUrl(fileId, timestamp);
}

void _doNothing([dynamic _]) {}
