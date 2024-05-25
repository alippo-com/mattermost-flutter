// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:mattermost_flutter/types.dart';

/// The App model will hold information - such as the version number, build number and creation date - 
/// for the Mattermost mobile app.
class InfoModel {
  static final String table = 'app'; // table (name)

  final String buildNumber; // Build number for the app
  final DateTime createdAt; // Date of creation for this version converted to DateTime
  final String versionNumber; // Version number for the app

  InfoModel({
    required this.buildNumber,
    required this.createdAt,
    required this.versionNumber,
  });

  // Method to convert a database row to an instance of InfoModel
  factory InfoModel.fromMap(Map<String, dynamic> map) {
    return InfoModel(
      buildNumber: map['buildNumber'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      versionNumber: map['versionNumber'],
    );
  }

  // Method to convert an instance of InfoModel to a database row
  Map<String, dynamic> toMap() {
    return {
      'buildNumber': buildNumber,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'versionNumber': versionNumber,
    };
  }
}
