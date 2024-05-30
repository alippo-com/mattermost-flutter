// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:watermelondb/watermelondb.dart';
import 'package:watermelondb/decorators.dart';
import 'package:mattermost_flutter/constants/database.dart';
import 'package:mattermost_flutter/types/database/models/servers/preference.dart';

const PREFERENCE = MM_TABLES.SERVER['PREFERENCE'];
const USER = MM_TABLES.SERVER['USER'];

/**
 * The Preference model holds information about the user's preference in the app.
 * This includes settings about the account, the themes, etc.
 */
class PreferenceModel extends Model with PreferenceModelInterface {
  /** table (name) : Preference */
  static final String tableName = PREFERENCE;

  /** associations : Describes every relationship to this table. */
  static final Map<String, Association> associations = {
    USER: Association(type: AssociationType.belongsTo, key: 'user_id'),
  };

  /** category : The preference category (e.g. Themes, Account settings, etc.) */
  @Field('category')
  late String category;

  /** name : The category name */
  @Field('name')
  late String name;

  /** user_id : The foreign key of the user's record in this model */
  @Field('user_id')
  late String userId;

  /** value : The preference's value */
  @Field('value')
  late String value;

  /** user : The related record to the parent User model */
  @ImmutableRelation(USER, 'user_id')
  late Relation<UserModel> user;
}
