// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/services.dart';
import 'dart:io';

class MattermostManaged {
  static const MethodChannel _channel = MethodChannel('mattermost_managed');

  static Future<Map<String, dynamic>> getIOSAppGroupDetails() async {
    final Map appGroupDetails = await _channel.invokeMethod('getConstants');
    return {
      'appGroupIdentifier': appGroupDetails['appGroupIdentifier'],
      'appGroupSharedDirectory': appGroupDetails['sharedDirectory'],
      'appGroupDatabase': appGroupDetails['databasePath']
    };
  }

  static Future<void> deleteIOSDatabase({String? databaseName, bool shouldRemoveDirectory = false}) async {
    await _channel.invokeMethod('deleteDatabaseDirectory', {
      'databaseName': databaseName,
      'shouldRemoveDirectory': shouldRemoveDirectory
    });
  }

  static Future<void> renameIOSDatabase(String from, String to) async {
    await _channel.invokeMethod('renameDatabase', {
      'from': from,
      'to': to
    });
  }

  static void deleteEntitiesFile(Function(bool success) callback) {
    if (Platform.isIOS) {
      _channel.invokeMethod('deleteEntitiesFile').then((result) {
        callback(result);
      });
    } else {
      callback(true);
    }
  }
}
