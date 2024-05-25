
// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:mattermost_flutter/types/model.dart';

/// The Role model will describe the set of permissions for each role
class RoleModel extends Model {
  /// table (name) : Role
  static const String table = 'Role';

  /// name: The role's name
  final String name;

  /// permissions: The different permissions associated to that role
  final List<String> permissions;

  RoleModel({required this.name, required this.permissions});

  @override
  String toString() {
    return 'RoleModel{name: \$name, permissions: \$permissions}';
  }
}
