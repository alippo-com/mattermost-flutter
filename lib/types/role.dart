// Copyright (c) 2021-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

/// The Role model will describe the set of permissions for each role
class RoleModel {
  /// table (name) : Role
  static const String table = 'Role';

  /// name  : The role's name
  String name;

  /// permissions : The different permissions associated to that role
  List<String> permissions;

  RoleModel({required this.name, required this.permissions});
}