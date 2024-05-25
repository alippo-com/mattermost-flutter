// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:mattermost_flutter/components/user_item/user_item.dart';
import 'package:mattermost_flutter/queries/servers/system.dart';
import 'package:mattermost_flutter/queries/servers/user.dart';
import 'package:mattermost_flutter/types/database/database.dart';
import 'package:rxdart/rxdart.dart';

class EnhancedUserItem extends StatelessWidget {
  final Database database;

  EnhancedUserItem({required this.database});

  @override
  Widget build(BuildContext context) {
    final isCustomStatusEnabled = observeConfigBooleanValue(database, 'EnableCustomUserStatuses');
    final currentUserId = observeCurrentUserId(database);
    final locale = observeCurrentUser(database).switchMap((u) => Stream.value(u?.locale)).distinct();
    final teammateNameDisplay = observeTeammateNameDisplay(database);
    final hideGuestTags = observeConfigBooleanValue(database, 'HideGuestTags');

    return UserItem(
      isCustomStatusEnabled: isCustomStatusEnabled,
      currentUserId: currentUserId,
      locale: locale,
      teammateNameDisplay: teammateNameDisplay,
      hideGuestTags: hideGuestTags,
    );
  }
}

EnhancedUserItem withDatabase(Database database) {
  return EnhancedUserItem(database: database);
}
