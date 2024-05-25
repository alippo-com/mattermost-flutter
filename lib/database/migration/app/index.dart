// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:sqflite/sqflite.dart';

// NOTE : To implement migration, please follow this document
// https://pub.dev/documentation/sqflite/latest/sqflite/Migration-class.html

final migrations = [
  Migration(1, 2, (Database db) async {
    // Implement migration logic from version 1 to 2
  }),
  Migration(2, 3, (Database db) async {
    // Implement migration logic from version 2 to 3
  }),
  // Add more migrations as needed
];
