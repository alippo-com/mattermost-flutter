
import 'package:flutter/material.dart';
import 'package:mattermost_flutter/types/database.dart';
import 'package:mattermost_flutter/models/servers/thread.dart';
import 'package:mattermost_flutter/queries/servers/thread.dart';
import 'package:mattermost_flutter/components/common_post_options/follow_thread_option.dart';
import 'package:provider/provider.dart';
import 'package:mattermost_flutter/utils/database.dart';

class EnhancedFollowThreadOption extends StatelessWidget {
  final ThreadModel thread;

  EnhancedFollowThreadOption({required this.thread});

  @override
  Widget build(BuildContext context) {
    final database = Provider.of<Database>(context);
    final teamId = observeTeamIdByThread(database, thread);

    return FollowThreadOption(teamId: teamId);
  }
}
