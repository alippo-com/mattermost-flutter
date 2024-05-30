
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:background_fetch/background_fetch.dart';
import 'package:rxdart/rxdart.dart';
import 'package:debounce_throttle/debounce_throttle.dart';

import '../actions/local/user.dart';
import '../actions/remote/user.dart';
import '../actions/websocket.dart';
import '../client/websocket.dart';
import '../constants.dart';
import '../database/manager.dart';
import '../queries/servers/system.dart';
import '../queries/servers/user.dart';
import '../utils/datetime.dart';
import '../utils/helpers.dart';
import '../utils/log.dart';

class WebsocketManager {
  final Map<String, BehaviorSubject<WebsocketConnectedState>> _connectedSubjects = {};
  final Map<String, WebSocketClient> _clients = {};
  final Map<String, Debouncer<void>> _connectionTimerIDs = {};
  bool _isBackgroundTimerRunning = false;
  bool _netConnected = false;
  bool _previousActiveState;
  final Map<String, Timer> _statusUpdatesIntervalIDs = {};
  int? _backgroundIntervalId;
  final Map<String, bool> _firstConnectionSynced = {};

  WebsocketManager() : _previousActiveState = WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;

  Future<void> init(List<ServerCredential> serverCredentials) async {
    _netConnected = (await Connectivity().checkConnectivity()) != ConnectivityResult.none;
    for (var credential in serverCredentials) {
      try {
        DatabaseManager.getServerDatabaseAndOperator(credential.serverUrl);
        _createClient(credential.serverUrl, credential.token, 0);
      } catch (error) {
        logError('WebsocketManager init error', error);
      }
    }

    WidgetsBinding.instance.addObserver(LifecycleEventHandler(
      detachedCallBack: () async => _onAppStateChange(AppLifecycleState.detached),
      resumedCallBack: () async => _onAppStateChange(AppLifecycleState.resumed),
    ));
    Connectivity().onConnectivityChanged.listen(_onNetStateChange);
  }

  void invalidateClient(String serverUrl) {
    _clients[serverUrl]?.close();
    _clients[serverUrl]?.invalidate();
    _connectionTimerIDs[serverUrl]?.cancel();
    _clients.remove(serverUrl);
    _firstConnectionSynced.remove(serverUrl);

    _getConnectedSubject(serverUrl).add('not_connected');
    _connectedSubjects.remove(serverUrl);
  }

  WebSocketClient _createClient(String serverUrl, String bearerToken, [int storedLastDisconnect = 0]) {
    _invalidateClient(serverUrl);

    final client = WebSocketClient(serverUrl, bearerToken, storedLastDisconnect);

    client.setFirstConnectCallback(() => _onFirstConnect(serverUrl));
    client.setEventCallback((evt) => handleEvent(serverUrl, evt));

    client.setReconnectCallback(() => _onReconnect(serverUrl));
    client.setReliableReconnectCallback(() => _onReliableReconnect(serverUrl));
    client.setCloseCallback((connectFailCount, lastDisconnect) => _onWebsocketClose(serverUrl, connectFailCount, lastDisconnect));

    _clients[serverUrl] = client;
    return _clients[serverUrl]!;
  }

  void closeAll() {
    _clients.forEach((url, client) {
      if (client.isConnected()) {
        client.close(true);
        _getConnectedSubject(url).add('not_connected');
      }
    });
  }

  Future<void> openAll() async {
    for (var clientUrl in _clients.keys) {
      final activeServerUrl = await DatabaseManager.getActiveServerUrl();
      if (clientUrl == activeServerUrl) {
        _initializeClient(clientUrl);
      } else {
        _getConnectedSubject(clientUrl).add('connecting');
        final bounce = Debouncer<void>(const Duration(seconds: 5), () => _initializeClient(clientUrl));
        _connectionTimerIDs[clientUrl] = bounce;
        bounce.call();
      }
    }
  }

  bool isConnected(String serverUrl) {
    return _clients[serverUrl]?.isConnected() ?? false;
  }

  Stream<WebsocketConnectedState> observeWebsocketState(String serverUrl) {
    return _getConnectedSubject(serverUrl).stream.distinct();
  }

  BehaviorSubject<WebsocketConnectedState> _getConnectedSubject(String serverUrl) {
    return _connectedSubjects.putIfAbsent(serverUrl, () => BehaviorSubject.seeded(isConnected(serverUrl) ? 'connected' : 'not_connected'));
  }

  void _cancelAllConnections() {
    _connectionTimerIDs.forEach((url, debouncer) {
      debouncer.cancel();
    });
    _connectionTimerIDs.clear();
  }

  Future<void> _initializeClient(String serverUrl) async {
    final client = _clients[serverUrl];
    _connectionTimerIDs[serverUrl]?.cancel();
    _connectionTimerIDs.remove(serverUrl);
    if (!(client?.isConnected() ?? false)) {
      client?.initialize();
      if (_firstConnectionSynced[serverUrl] != true) {
        final error = await handleFirstConnect(serverUrl);
        if (error != null) {
          client?.close(false);
        }
        if (_clients.containsKey(serverUrl)) {
          _firstConnectionSynced[serverUrl] = true;
        }
      }
    }
  }

  void _onFirstConnect(String serverUrl) {
    _startPeriodicStatusUpdates(serverUrl);
    _getConnectedSubject(serverUrl).add('connected');
  }

  Future<void> _onReconnect(String serverUrl) async {
    _startPeriodicStatusUpdates(serverUrl);
    _getConnectedSubject(serverUrl).add('connected');
    final error = await handleReconnect(serverUrl);
    if (error != null) {
      _getClient(serverUrl)?.close(false);
    }
  }

  Future<void> _onReliableReconnect(String serverUrl) async {
    _getConnectedSubject(serverUrl).add('connected');
  }

  Future<void> _onWebsocketClose(String serverUrl, int connectFailCount, int lastDisconnect) async {
    _getConnectedSubject(serverUrl).add('not_connected');
    if (connectFailCount <= 1) {
      await setCurrentUserStatus(serverUrl, General.OFFLINE);
      await handleClose(serverUrl, lastDisconnect);

      _stopPeriodicStatusUpdates(serverUrl);
    }
  }

  void _startPeriodicStatusUpdates(String serverUrl) {
    _statusUpdatesIntervalIDs[serverUrl]?.cancel();
    final timer = Timer.periodic(Duration(milliseconds: General.STATUS_INTERVAL), (_) async {
      final database = DatabaseManager.serverDatabases[serverUrl];
      if (database == null) return;

      final currentUserId = await getCurrentUserId(database.database);
      final userIds = (await queryAllUsers(database.database).fetchIds()).where((id) => id != currentUserId).toList();

      fetchStatusByIds(serverUrl, userIds);
    });
    _statusUpdatesIntervalIDs[serverUrl] = timer;
  }

  void _stopPeriodicStatusUpdates(String serverUrl) {
    _statusUpdatesIntervalIDs[serverUrl]?.cancel();
    _statusUpdatesIntervalIDs.remove(serverUrl);
  }

  Future<void> _onAppStateChange(AppLifecycleState state) async {
    final isActive = state == AppLifecycleState.resumed;
    if (isActive == _previousActiveState) return;

    final isMain = isMainActivity();

    _cancelAllConnections();
    if (!isActive && !_isBackgroundTimerRunning) {
      _isBackgroundTimerRunning = true;
      _cancelAllConnections();
      _backgroundIntervalId = BackgroundFetch.scheduleTask(TaskConfig(
        taskId: 'backgroundTask',
        delay: Duration(milliseconds: 15000),
        periodic: false,
        stopOnTerminate: false,
      ));
      BackgroundFetch.start().then((int status) {
        if (status == BackgroundFetch.STATUS_AVAILABLE) {
          BackgroundFetch.finish(_backgroundIntervalId!);
          _isBackgroundTimerRunning = false;
        }
      });

      _previousActiveState = isActive;
      return;
    }

    if (isActive && _netConnected && isMain) {
      if (_backgroundIntervalId != null) {
        BackgroundFetch.finish(_backgroundIntervalId!);
      }
      _isBackgroundTimerRunning = false;
      openAll();
      _previousActiveState = isActive;
      return;
    }

    if (isMain) {
      _previousActiveState = isActive;
    }
  }

  Future<void> _onNetStateChange(ConnectivityResult result) async {
    final newState = result != ConnectivityResult.none;
    if (_netConnected == newState) return;

    _netConnected = newState;

    if (_netConnected && _previousActiveState) {
      openAll();
      return;
    }

    closeAll();
  }

  WebSocketClient? _getClient(String serverUrl) {
    return _clients[serverUrl];
  }
}

class LifecycleEventHandler extends WidgetsBindingObserver {
  final AsyncCallback? detachedCallBack;
  final AsyncCallback? resumedCallBack;

  LifecycleEventHandler({this.detachedCallBack, this.resumedCallBack});

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.detached:
        if (detachedCallBack != null) await detachedCallBack!();
        break;
      case AppLifecycleState.resumed:
        if (resumedCallBack != null) await resumedCallBack!();
        break;
      default:
        break;
    }
  }
}

enum WebsocketConnectedState { connected, not_connected, connecting }

class ServerCredential {
  final String serverUrl;
  final String token;

  ServerCredential({required this.serverUrl, required this.token});
}

