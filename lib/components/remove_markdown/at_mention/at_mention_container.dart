// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mattermost_flutter/database/database.dart';
import 'package:mattermost_flutter/queries/group.dart';
import 'package:mattermost_flutter/queries/user.dart';
import 'package:mattermost_flutter/components/remove_markdown/at_mention/at_mention.dart';
import 'package:mattermost_flutter/types/database/database.dart';

class AtMentionContainer extends StatelessWidget {
  final String mentionName;

  AtMentionContainer({required this.mentionName});

  @override
  Widget build(BuildContext context) {
    final database = Provider.of<Database>(context);
    final teammateNameDisplay = observeTeammateNameDisplay(database);

    String mn = mentionName.toLowerCase();
    if (RegExp(r'[._-]$').hasMatch(mn)) {
      mn = mn.substring(0, mn.length - 1);
    }

    final users = queryUsersLike(database, mn);
    final groups = queryGroupsByName(database, mn);

    return AtMention(
      teammateNameDisplay: teammateNameDisplay,
      users: users,
      groups: groups,
    );
  }
}
