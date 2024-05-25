import 'package:flutter/material.dart';
import 'package:mattermost_flutter/managers/apps_manager.dart';
import 'package:mattermost_flutter/queries/servers/system.dart';
import 'package:rxdart/rxdart.dart';

class WithDatabaseArgs {
  final dynamic database;
  WithDatabaseArgs({required this.database});
}

class EnhancedSlashSuggestion extends StatelessWidget {
  final WithDatabaseArgs args;
  const EnhancedSlashSuggestion({required this.args});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, dynamic>>(
      stream: observeDatabaseValues(args.database),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final data = snapshot.data!;
          return AppSlashSuggestion(
            currentTeamId: data['currentTeamId'],
            isAppsEnabled: data['isAppsEnabled'],
          );
        } else {
          return Container(); // Return an empty container or a fallback widget
        }
      },
    );
  }
}

class AppSlashSuggestion extends StatelessWidget {
  final String currentTeamId;
  final bool isAppsEnabled;
  const AppSlashSuggestion({required this.currentTeamId, required this.isAppsEnabled});

  @override
  Widget build(BuildContext context) {
    // Build your AppSlashSuggestion widget here
    return Container();
  }
}

Stream<Map<String, dynamic>> observeDatabaseValues(database) {
  // Implement your database observation logic here
  return Rx.combineLatest2(
    observeCurrentTeamId(database),
    observeConfigBooleanValue(database, 'FeatureFlagAppsEnabled'),
    (currentTeamId, isAppsEnabled) => {
      'currentTeamId': currentTeamId,
      'isAppsEnabled': isAppsEnabled,
    },
  );
}
