// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:mattermost_flutter/types/database/models/servers/role.dart'; // adjusted import path

/// The Role model will describe the set of permissions for each role
class RoleModel {
  static const String table = 'Role'; // Static constant for table name

  final String name; // The role's name
  final List<String> permissions; // The different permissions associated to that role

  RoleModel({required this.name, required this.permissions}); // Constructor with required fields
}