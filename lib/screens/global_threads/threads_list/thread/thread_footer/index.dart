import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mattermost_flutter/types/database.dart';
import 'package:mattermost_flutter/models/thread.dart';
import 'thread_footer.dart';

class EnhancedThreadFooter extends StatelessWidget {
  final ThreadModel thread;

  EnhancedThreadFooter({required this.thread});

  @override
  Widget build(BuildContext context) {
    final participants = Provider.of<Database>(context)
        .queryThreadParticipants(thread.id)
        .observe();

    return ThreadFooter(participants: participants);
  }
}

class WithDatabase extends StatelessWidget {
  final Widget child;

  WithDatabase({required this.child});

  @override
  Widget build(BuildContext context) {
    return Provider<Database>(
      create: (_) => Database(),
      child: child,
    );
  }
}

void main() {
  runApp(
    WithDatabase(
      child: EnhancedThreadFooter(
        thread: ThreadModel(id: 'sampleId'), // Replace with actual thread ID
      ),
    ),
  );
}
