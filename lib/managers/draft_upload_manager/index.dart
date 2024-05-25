// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mattermost_flutter/actions/local_draft.dart';
import 'package:mattermost_flutter/actions/remote_file.dart';
import 'package:mattermost_flutter/constants/files.dart';
import 'package:mattermost_flutter/utils/errors.dart';
import 'package:mattermost_flutter/types/client_response.dart';
import 'package:mattermost_flutter/types/client_response_error.dart';
import 'package:mattermost_flutter/types/file_info.dart';

typedef FileHandler = Map<String, Map<String, dynamic>>;

class DraftUploadManager {
  FileHandler handlers = {};
  AppLifecycleState previousAppState = AppLifecycleState.resumed;

  DraftUploadManager() {
    SystemChannels.lifecycle.setMessageHandler((msg) async {
      if (msg == 'AppLifecycleState.paused') {
        await onAppStateChange(AppLifecycleState.paused);
      } else if (msg == 'AppLifecycleState.resumed') {
        await onAppStateChange(AppLifecycleState.resumed);
      }
      return;
    });
  }

  void prepareUpload(
    String serverUrl,
    FileInfo file,
    String channelId,
    String rootId, [
    int skipBytes = 0,
  ]) {
    handlers[file.clientId] = {
      'fileInfo': file,
      'serverUrl': serverUrl,
      'channelId': channelId,
      'rootId': rootId,
      'lastTimeStored': 0,
      'onError': [],
      'onProgress': [],
    };

    void onProgress(double progress, [int bytesRead = 0]) {
      handleProgress(file.clientId, progress, bytesRead);
    }

    void onComplete(ClientResponse response) {
      handleComplete(response, file.clientId);
    }

    void onError(ClientResponseError response) {
      final message = response.message ?? 'Unknown error';
      handleError(message, file.clientId);
    }

    final result = uploadFile(
      serverUrl,
      file,
      channelId,
      onProgress,
      onComplete,
      onError,
      skipBytes,
    );

    if (result.error != null) {
      handleError(getFullErrorMessage(result.error!), file.clientId);
      return;
    }

    handlers[file.clientId]['cancel'] = result.cancel;
  }

  void cancel(String clientId) {
    if (handlers[clientId]?['cancel'] != null) {
      handlers[clientId]['cancel']();
      handlers.remove(clientId);
    }
  }

  bool isUploading(String clientId) {
    return handlers[clientId] != null;
  }

  Function? registerProgressHandler(
      String clientId, void Function(double, int) callback) {
    if (handlers[clientId] == null) {
      return null;
    }

    handlers[clientId]['onProgress'].add(callback);
    return () {
      if (handlers[clientId] == null) {
        return;
      }
      handlers[clientId]['onProgress']
          .removeWhere((element) => element == callback);
    };
  }

  Function? registerErrorHandler(
      String clientId, void Function(String) callback) {
    if (handlers[clientId] == null) {
      return null;
    }

    handlers[clientId]['onError'].add(callback);
    return () {
      if (handlers[clientId] == null) {
        return;
      }
      handlers[clientId]['onError']
          .removeWhere((element) => element == callback);
    };
  }

  void handleProgress(String clientId, double progress, int bytes) {
    final handler = handlers[clientId];
    if (handler == null) {
      return;
    }

    handler['fileInfo'].bytesRead = bytes;
    for (final callback in handler['onProgress']) {
      callback(progress, bytes);
    }

    if (previousAppState != AppLifecycleState.resumed &&
        handler['lastTimeStored'] + PROGRESS_TIME_TO_STORE < DateTime.now().millisecondsSinceEpoch) {
      updateDraftFile(handler['serverUrl'], handler['channelId'], handler['rootId'],
          handlers[clientId]['fileInfo']);
      handler['lastTimeStored'] = DateTime.now().millisecondsSinceEpoch;
    }
  }

  void handleComplete(ClientResponse response, String clientId) {
    final handler = handlers[clientId];
    if (handler == null) {
      return;
    }

    if (response.code != 201) {
      handleError(response.data?['message'] ?? 'Failed to upload the file: unknown error', clientId);
      return;
    }

    if (response.data == null) {
      handleError('Failed to upload the file: no data received', clientId);
      return;
    }

    final data = response.data['file_infos'] as List<FileInfo>?;
    if (data == null || data.isEmpty) {
      handleError('Failed to upload the file: no data received', clientId);
      return;
    }

    handlers.remove(clientId);

    final fileInfo = data[0];
    fileInfo.clientId = handler['fileInfo'].clientId;
    fileInfo.localPath = handler['fileInfo'].localPath;

    updateDraftFile(handler['serverUrl'], handler['channelId'], handler['rootId'], fileInfo);
  }

  void handleError(String errorMessage, String clientId) {
    final handler = handlers[clientId];
    if (handler == null) {
      return;
    }

    handlers.remove(clientId);

    for (final callback in handler['onError']) {
      callback(errorMessage);
    }

    final fileInfo = handler['fileInfo'];
    fileInfo.failed = true;
    updateDraftFile(handler['serverUrl'], handler['channelId'], handler['rootId'], fileInfo);
  }

  Future<void> onAppStateChange(AppLifecycleState appState) async {
    if (appState != AppLifecycleState.resumed &&
        previousAppState == AppLifecycleState.resumed) {
      await storeProgress();
    }

    previousAppState = appState;
  }

  Future<void> storeProgress() async {
    for (final handler in handlers.values) {
      await updateDraftFile(
        handler['serverUrl'],
        handler['channelId'],
        handler['rootId'],
        handler['fileInfo'],
      );
      handler['lastTimeStored'] = DateTime.now().millisecondsSinceEpoch;
    }
  }
}

final draftUploadManager = DraftUploadManager();

final exportedForTesting = {
  'DraftUploadManager': DraftUploadManager,
};
