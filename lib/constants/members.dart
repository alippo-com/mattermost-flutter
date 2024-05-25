// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

// Dart imports
import 'package:flutter/foundation.dart';

enum ManageOptions {
  REMOVE_USER,
  MAKE_CHANNEL_ADMIN,
  MAKE_CHANNEL_MEMBER,
}

extension ManageOptionsExtension on ManageOptions {
  String get name => describeEnum(this);
}

final manageOptions = {
  'REMOVE_USER': ManageOptions.REMOVE_USER,
  'MAKE_CHANNEL_ADMIN': ManageOptions.MAKE_CHANNEL_ADMIN,
  'MAKE_CHANNEL_MEMBER': ManageOptions.MAKE_CHANNEL_MEMBER,
};
