
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mattermost_flutter/types/database.dart';
import 'package:mattermost_flutter/queries/servers/post.dart';
import 'post_priority_picker.dart';

class EnhancedPostPriorityPicker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final database = Provider.of<Database>(context);

    final isPostAcknowledgementEnabled = observeIsPostAcknowledgementsEnabled(database);
    final isPersistentNotificationsEnabled = observePersistentNotificationsEnabled(database);
    final persistentNotificationInterval = observeConfigIntValue(database, 'PersistentNotificationIntervalMinutes');

    return PostPriorityPicker(
      isPostAcknowledgementEnabled: isPostAcknowledgementEnabled,
      isPersistentNotificationsEnabled: isPersistentNotificationsEnabled,
      persistentNotificationInterval: persistentNotificationInterval,
    );
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
      child: EnhancedPostPriorityPicker(),
    ),
  );
}
