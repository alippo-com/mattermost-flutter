
// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:watermelondb/watermelondb.dart';
import 'package:watermelondb/Relation.dart';

/**
 * The Preference model holds information about the user's preference in the app.
 * This includes settings about the account, the themes, etc.
 */
class PreferenceModel extends Model {
  static final String table = 'Preference';

  String category;
  String name;
  String userId;
  String value;
  Relation<UserModel> user;

  PreferenceModel({
    required this.category,
    required this.name,
    required this.userId,
    required this.value,
    required this.user,
  });

  static final Map<String, dynamic> associations = {
    // Define associations if needed
  };
}
