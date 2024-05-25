// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:mattermost_flutter/types/role.dart';

bool hasPermission(List<RoleModel> roles, String permission) {
  var permissions = <String>{};
  for (var role in roles) {
    permissions.addAll(role.permissions);
  }

  return permissions.contains(permission);
}