// Dart Code: ./mattermost_flutter/lib/managers/integrations_manager.dart

import 'package:mattermost_flutter/constants/screens.dart';

const int timeToRefetchCommands = 60000; // 1 minute

class ServerIntegrationsManager {
  final String serverUrl;
  final Map<String, int?> commandsLastFetched = {};
  final Map<String, List<Command>?> commands = {};

  String triggerId = '';
  InteractiveDialogConfig? storedDialog;

  ServerIntegrationsManager(this.serverUrl);

  Future<List<Command>> fetchCommands(String teamId) async {
    final lastFetched = commandsLastFetched[teamId] ?? 0;
    final lastCommands = commands[teamId];
    if (lastCommands != null && lastFetched + timeToRefetchCommands > DateTime.now().millisecondsSinceEpoch) {
      return lastCommands;
    }

    try {
      final res = await fetchCommands(serverUrl, teamId);
      if (res.containsKey('error')) {
        return [];
      }
      commands[teamId] = res['commands'];
      commandsLastFetched[teamId] = DateTime.now().millisecondsSinceEpoch;
      return res['commands'];
    } catch (e) {
      return [];
    }
  }

  void setTriggerId(String id) {
    triggerId = id;
    if (storedDialog?.triggerId == id) {
      showDialog();
    }
  }

  void setDialog(InteractiveDialogConfig dialog) {
    storedDialog = dialog;
    if (triggerId == dialog.triggerId) {
      showDialog();
    }
  }

  void showDialog() {
    final config = storedDialog;
    if (config == null) {
      return;
    }
    showModal(INTERACTIVE_DIALOG, config.dialog.title, {'config': config});
  }
}

class IntegrationsManager {
  final Map<String, ServerIntegrationsManager?> serverManagers = {};

  ServerIntegrationsManager getManager(String serverUrl) {
    serverManagers.putIfAbsent(serverUrl, () => ServerIntegrationsManager(serverUrl));
    return serverManagers[serverUrl]!;
  }
}

final integrationsManager = IntegrationsManager();
