// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:mattermost_flutter/context/server.dart';
import 'package:mattermost_flutter/database/models/server/group.dart';
import 'package:mattermost_flutter/hooks/markdown.dart';

class AtMention extends StatefulWidget {
  final Database database;
  final String mentionName;
  final String teammateNameDisplay;
  final TextStyle? textStyle;
  final List<UserModelType> users;
  final List<GroupModel> groups;

  const AtMention({
    required this.database,
    required this.mentionName,
    required this.teammateNameDisplay,
    this.textStyle,
    required this.users,
    required this.groups,
  });

  @override
  _AtMentionState createState() => _AtMentionState();
}

class _AtMentionState extends State<AtMention> {
  late String mention;

  @override
  void initState() {
    super.initState();
    fetchMention();
  }

  void fetchMention() {
    final serverUrl = useServerUrl();
    final user = useMemoMentionedUser(widget.users, widget.mentionName);
    final group = useMemoMentionedGroup(widget.groups, user, widget.mentionName);

    if (user?.username == null && group?.name == null) {
      fetchUserOrGroupsByMentionsInBatch(serverUrl, widget.mentionName);
    }

    if (user?.username != null) {
      mention = displayUsername(user, user.locale, widget.teammateNameDisplay);
    } else if (group?.name != null) {
      mention = group.name;
    } else {
      final pattern = RegExp(r'(all|channel|here)(?:\.\B|_|)', caseSensitive: false);
      final mentionMatch = pattern.firstMatch(widget.mentionName);

      if (mentionMatch != null) {
        mention = mentionMatch.group(1) ?? mentionMatch.group(0)!;
      } else {
        mention = widget.mentionName;
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      '@$mention',
      style: widget.textStyle,
    );
  }
}
