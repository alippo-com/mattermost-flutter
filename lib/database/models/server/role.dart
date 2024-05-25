// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:watermelondb/watermelondb.dart';
import 'package:watermelondb/decorators.dart';

import 'package:mattermost_flutter/constants/database.dart';
import 'package:mattermost_flutter/utils/helpers.dart';

import 'package:mattermost_flutter/types/role.dart';

/** The Role model will describe the set of permissions for each role */
class RoleModel extends Model implements RoleModelInterface {
  /** table (name) : Role */
  static final table = MM_TABLES.SERVER.ROLE;

  /** name  : The role's name */
  @Field('name')
  late final String name;

  /** permissions : The different permissions associated to that role */
  @Json('permissions', safeParseJSON)
  late final List<String> permissions;
}
