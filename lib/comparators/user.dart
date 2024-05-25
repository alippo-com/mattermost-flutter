
// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:mattermost_flutter/types/user_model.dart';

bool shouldUpdateUserRecord(UserModel e, UserProfile n) {
  return (n.updateAt > e.updateAt) || (n.status != null && n.status != e.status);
}
