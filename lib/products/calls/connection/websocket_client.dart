// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'dart:async';
import 'dart:convert';
import 'package:events/events.dart';
import 'package:msgpack_dart/msgpack_dart.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:mattermost_flutter/constants/calls.dart';
import 'package:mattermost_flutter/database/manager.dart';
import 'package:mattermost_flutter/queries/servers/system.dart';
import 'package:mattermost_flutter/utils/log.dart';

const wsMinReconnectRetryTimeMs = 1000; // 1 second
const wsReconnectionTimeout = 30000; // 30 seconds
const wsReconnectTimeIncrement = 500; // 0.5 seconds
const wsReconnectionTimeoutErr = 'max disconnected time reached';

class WebSocketClient extends EventEmitter {
  final String serverUrl;
  final String wsPath;
  String authToken;
  WebSocketChannel? ws;
  int seqNo = 1;
  int serverSeqNo = 0;
  String connID = '';
  String originalConnID = '';
  int lastDisconnect = 0;
  int reconnectRetryTime = wsMinReconnectRetryTimeMs;
  bool closed = false;
  String eventPrefix = 'custom_${Calls.PluginId}';

  WebSocketClient(this.serverUrl, this.wsPath, [this.authToken = '']) : super();

  Future<void> init(bool isReconnect) async {
    final database = DatabaseManager.serverDatabases[serverUrl]?.database;
    if (database == null) {
      return;
    }

    final websocketURL = await getConfigValue(database, 'WebsocketURL');
    final connectionUrl = (websocketURL ?? serverUrl) + wsPath;

    ws = WebSocketChannel.connect(
      Uri.parse('$connectionUrl?connection_id=$connID&sequence_number=$serverSeqNo'),
      headers: {'authorization': 'Bearer $authToken'},
    );

    if (isReconnect) {
      ws!.stream.listen((_) {
        lastDisconnect = 0;
        reconnectRetryTime = wsMinReconnectRetryTimeMs;
        emit('open', [originalConnID, connID, true]);
      }, onError: (error) {
        emit('error', [error]);
      }, onDone: () {
        emit('close', []);
        if (!closed) {
          reconnect();
        }
      });
    }

    ws!.stream.listen((message) {
      if (message == null) {
        return;
      }
      dynamic msg;
      try {
        msg = jsonDecode(message);
      } catch (error) {
        logError('calls: ws msg parse error', error);
        return;
      }

      if (msg != null) {
        serverSeqNo = msg['seq'] + 1;
      }

      if (msg == null || msg['event'] == null || msg['data'] == null) {
        return;
      }

      if (msg['event'] == 'hello') {
        if (msg['data']['connection_id'] != connID) {
          logDebug('calls: ws new conn id from server');
          connID = msg['data']['connection_id'];
          serverSeqNo = 0;
          if (originalConnID == '') {
            logDebug('calls: ws setting original conn id');
            originalConnID = connID;
          }
        }
        if (!isReconnect) {
          emit('open', [originalConnID, connID, false]);
        }
        return;
      } else if (connID == '') {
        logDebug('calls: ws message received while waiting for hello');
        return;
      }

      if (msg['data']['connID'] != connID && msg['data']['connID'] != originalConnID) {
        return;
      }

      if (msg['event'] == '${eventPrefix}_join') {
        emit('join', []);
      }

      if (msg['event'] == '${eventPrefix}_error') {
        emit('error', [msg['data']]);
      }

      if (msg['event'] == '${eventPrefix}_signal') {
        emit('message', [msg['data']]);
      }
    });
  }

  Future<void> initialize() async {
    await init(false);
  }

  void send(String action, [dynamic data, bool binary = false]) {
    final msg = {
      'action': '${eventPrefix}_$action',
      'seq': seqNo++,
      'data': data,
    };
    if (ws != null && ws!.sink != null) {
      if (binary) {
        ws!.sink.add(encode(msg));
      } else {
        ws!.sink.add(jsonEncode(msg));
      }
    }
  }

  void close() {
    closed = true;
    ws?.sink.close();
    ws = null;
    seqNo = 1;
    serverSeqNo = 0;
    connID = '';
    originalConnID = '';
  }

  void reconnect() {
    final now = DateTime.now().millisecondsSinceEpoch;
    if (lastDisconnect == 0) {
      lastDisconnect = now;
    }

    if ((now - lastDisconnect) >= wsReconnectionTimeout) {
      closed = true;
      emit('error', [wsReconnectionTimeoutErr]);
      return;
    }

    Future.delayed(Duration(milliseconds: reconnectRetryTime), () {
      if (!closed) {
        logDebug('calls: attempting ws reconnection to ${serverUrl + wsPath}');
        init(true);
      }
    });

    reconnectRetryTime += wsReconnectTimeIncrement;
  }

  int state() {
    if (closed || ws == null) {
      return WebSocketChannel.closed;
    }
    return ws!.sink.hashCode; // Not exact equivalent but a placeholder
  }
}
