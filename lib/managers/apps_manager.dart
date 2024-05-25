import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:mattermost_flutter/database/manager.dart';
import 'package:mattermost_flutter/queries/servers/channel.dart';
import 'package:mattermost_flutter/queries/servers/system.dart';
import 'package:mattermost_flutter/utils/apps.dart';
import 'package:mattermost_flutter/utils/errors.dart';
import 'package:mattermost_flutter/utils/log.dart';
import 'network_manager.dart';

final emptyBindings = <AppBinding>[];

List<AppBinding> normalizeBindings(List<AppBinding> bindings) {
  return bindings.fold<List<AppBinding>>(<AppBinding>[], (acc, v) {
    return v.bindings != null ? acc..addAll(v.bindings!) : acc;
  });
}

class AppsManager {
  final Map<String, BehaviorSubject<bool>> enabled = {};
  final Map<String, BehaviorSubject<List<AppBinding>>> bindings = {};
  final Map<String, BehaviorSubject<ThreadBindings>> threadBindings = {};
  final Map<String, Map<String, AppForm>> commandForms = {};
  final Map<String, Map<String, AppForm>> threadCommandForms = {};

  BehaviorSubject<bool> getEnabledSubject(String serverUrl) {
    if (!enabled.containsKey(serverUrl)) {
      enabled[serverUrl] = BehaviorSubject<bool>.seeded(true);
    }
    return enabled[serverUrl]!;
  }

  BehaviorSubject<List<AppBinding>> getBindingsSubject(String serverUrl) {
    if (!bindings.containsKey(serverUrl)) {
      bindings[serverUrl] = BehaviorSubject<List<AppBinding>>.seeded([]);
    }
    return bindings[serverUrl]!;
  }

  BehaviorSubject<ThreadBindings> getThreadsBindingsSubject(String serverUrl) {
    if (!threadBindings.containsKey(serverUrl)) {
      threadBindings[serverUrl] = BehaviorSubject<ThreadBindings>.seeded(ThreadBindings(channelId: '', bindings: emptyBindings));
    }
    return threadBindings[serverUrl]!;
  }

  void handleError(String serverUrl) {
    final enabledSubject = getEnabledSubject(serverUrl);
    if (enabledSubject.value) {
      enabledSubject.add(false);
    }
    getBindingsSubject(serverUrl).add(emptyBindings);
    getThreadsBindingsSubject(serverUrl).add(ThreadBindings(channelId: '', bindings: emptyBindings));
    commandForms[serverUrl] = {};
    threadCommandForms[serverUrl] = {};
  }

  void removeServer(String serverUrl) {
    enabled.remove(serverUrl);
    bindings.remove(serverUrl);
    threadBindings.remove(serverUrl);
    commandForms.remove(serverUrl);
    threadCommandForms.remove(serverUrl);
  }

  void clearServer(String serverUrl) {
    clearBindings(serverUrl);
    clearBindings(serverUrl, forThread: true);
    commandForms[serverUrl] = {};
    threadCommandForms[serverUrl] = {};
  }

  Future<bool> isAppsEnabled(String serverUrl) async {
    try {
      final database = await DatabaseManager.getServerDatabaseAndOperator(serverUrl);
      final config = await getConfig(database);
      return getEnabledSubject(serverUrl).value && config?.featureFlagAppsEnabled == 'true';
    } catch {
      return false;
    }
  }

  Stream<bool> observeIsAppsEnabled(String serverUrl) {
    try {
      final database = DatabaseManager.getServerDatabaseAndOperator(serverUrl);
      final enabledStream = getEnabledSubject(serverUrl).stream;
      final configStream = observeConfigBooleanValue(database, 'FeatureFlagAppsEnabled');
      return Rx.combineLatest2(enabledStream, configStream, (bool e, bool cfg) => e && cfg).distinct();
    } catch {
      return Stream.value(false);
    }
  }

  Future<void> fetchBindings(String serverUrl, String channelId, {bool forThread = false}) async {
    try {
      final database = await DatabaseManager.getServerDatabaseAndOperator(serverUrl);
      final userId = await getCurrentUserId(database);
      final channel = await getChannelById(database, channelId);
      var teamId = channel?.teamId;
      if (teamId == null) {
        teamId = await getCurrentTeamId(database);
      }

      final client = NetworkManager.getClient(serverUrl);
      final fetchedBindings = await client.getAppsBindings(userId, channelId, teamId);
      final validatedBindings = validateBindings(fetchedBindings);
      final bindingsToStore = validatedBindings.isNotEmpty ? validatedBindings : emptyBindings;

      final enabledSubject = getEnabledSubject(serverUrl);
      if (!enabledSubject.value) {
        enabledSubject.add(true);
      }
      if (forThread) {
        getThreadsBindingsSubject(serverUrl).add(ThreadBindings(channelId: channelId, bindings: bindingsToStore));
        threadCommandForms[serverUrl] = {};
      } else {
        getBindingsSubject(serverUrl).add(bindingsToStore);
        commandForms[serverUrl] = {};
      }
    } catch (error) {
      logDebug('error on fetchBindings', getFullErrorMessage(error));
      handleError(serverUrl);
    }
  }

  Future<void> refreshAppBindings(String serverUrl) async {
    try {
      final database = await DatabaseManager.getServerDatabaseAndOperator(serverUrl);
      final appsEnabled = (await getConfig(database))?.featureFlagAppsEnabled == 'true';
      if (!appsEnabled) {
        getEnabledSubject(serverUrl).add(false);
        clearServer(serverUrl);
      }

      final channelId = await getCurrentChannelId(database);

      await fetchBindings(serverUrl, channelId);

      final threadChannelId = getThreadsBindingsSubject(serverUrl).value.channelId;
      if (threadChannelId.isNotEmpty) {
        await fetchBindings(serverUrl, threadChannelId, forThread: true);
      }
    } catch (error) {
      logDebug('Error refreshing apps', error);
      handleError(serverUrl);
    }
  }

  Future<void> copyMainBindingsToThread(String serverUrl, String channelId) async {
    getThreadsBindingsSubject(serverUrl).add(ThreadBindings(channelId: channelId, bindings: getBindingsSubject(serverUrl).value));
  }

  Future<void> clearBindings(String serverUrl, {bool forThread = false}) async {
    if (forThread) {
      getThreadsBindingsSubject(serverUrl).add(ThreadBindings(channelId: '', bindings: emptyBindings));
    } else {
      getBindingsSubject(serverUrl).add(emptyBindings);
    }
  }

  Stream<List<AppBinding>> observeBindings(String serverUrl, {String? location, bool forThread = false}) {
    final isEnabledStream = observeIsAppsEnabled(serverUrl);
    final bindingsStream = forThread
        ? getThreadsBindingsSubject(serverUrl).stream.map((tb) => tb.bindings)
        : getBindingsSubject(serverUrl).stream;

    return Rx.combineLatest2(isEnabledStream, bindingsStream, (bool e, List<AppBinding> bb) => e ? bb : emptyBindings).switchMap((bb) {
      var result = location != null ? bb.where((b) => b.location == location).toList() : bb;
      result = normalizeBindings(result);
      return Stream.value(result.isNotEmpty ? result : emptyBindings);
    });
  }

  List<AppBinding> getBindings(String serverUrl, {String? location, bool forThread = false}) {
    var bindings = forThread
        ? getThreadsBindingsSubject(serverUrl).value.bindings
        : getBindingsSubject(serverUrl).value;

    if (location != null) {
      bindings = bindings.where((b) => b.location == location).toList();
    }

    return normalizeBindings(bindings);
  }

  AppForm? getCommandForm(String serverUrl, String key, {bool forThread = false}) {
    return forThread ? threadCommandForms[serverUrl]?[key] : commandForms[serverUrl]?[key];
  }

  void setCommandForm(String serverUrl, String key, AppForm form, {bool forThread = false}) {
    final toStore = forThread ? threadCommandForms : commandForms;
    if (!toStore.containsKey(serverUrl)) {
      toStore[serverUrl] = {};
    }
    toStore[serverUrl]![key] = form;
  }
}

class ThreadBindings {
  String channelId;
  List<AppBinding> bindings;

  ThreadBindings({required this.channelId, required this.bindings});
}

class AppBinding {
  String? location;
  List<AppBinding>? bindings;

  AppBinding({this.location, this.bindings});
}

class AppForm {}

class NetworkManager {
  static NetworkManager getClient(String serverUrl) {
    // Dummy implementation to satisfy the compiler
    return NetworkManager();
  }

  Future<List<AppBinding>> getAppsBindings(String userId, String channelId, String teamId) async {
    // Dummy implementation to satisfy the compiler
    return [];
  }
}
