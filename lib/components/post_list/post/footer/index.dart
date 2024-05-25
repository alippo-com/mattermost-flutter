// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mattermost_flutter/database/database.dart';
import 'package:mattermost_flutter/queries/servers/thread.dart';
import 'footer.dart';
import 'package:mattermost_flutter/types.dart';

class EnhancedFooter extends StatelessWidget {
  final ThreadModel thread;

  EnhancedFooter({required this.thread});

  @override
  Widget build(BuildContext context) {
    final database = Provider.of<Database>(context);

    final participantsStream = queryThreadParticipants(database, thread.id);
    final teamIdStream = observeTeamIdByThread(database, thread);

    return MultiProvider(
      providers: [
        StreamProvider<List<Participant>>(
          create: (_) => participantsStream,
          initialData: [],
        ),
        StreamProvider<String>(
          create: (_) => teamIdStream,
          initialData: '',
        ),
      ],
      child: Footer(),
    );
  }
}

class Footer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final participants = Provider.of<List<Participant>>(context);
    final teamId = Provider.of<String>(context);

    // Implement the rest of your Footer widget based on participants and teamId

    return Container(); // Placeholder for actual footer content
  }
}
