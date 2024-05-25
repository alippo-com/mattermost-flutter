
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:mattermost_flutter/types/calls.dart';
import 'package:mattermost_flutter/utils/calls.dart';
import 'package:mattermost_flutter/utils/log.dart';
import 'package:mattermost_flutter/utils/network_manager.dart';
import 'package:mattermost_flutter/utils/theme.dart';

const int peerConnectTimeout = 5000;
const int rtcMonitorInterval = 4000;

class Connection {
  final String serverUrl;
  final String channelId;
  final Function(Error?) closeCb;
  final Function(String) setScreenShareUrl;
  final bool hasMicPermission;
  final String? title;
  final String? rootId;

  RTCPeer? peer;
  MediaStream? stream;
  bool voiceTrackAdded = false;
  MediaStreamTrack? voiceTrack;
  bool isClosed = false;
  StreamSubscription? onCallEnd;
  StreamSubscription? audioDeviceChanged;
  StreamSubscription? wiredHeadsetEvent;
  List<MediaStream> streams = [];
  RTCMonitor? rtcMonitor;
  WebSocketClient? ws;

  Connection({
    required this.serverUrl,
    required this.channelId,
    required this.closeCb,
    required this.setScreenShareUrl,
    required this.hasMicPermission,
    this.title,
    this.rootId,
  });

  Future<void> initializeVoiceTrack() async {
    if (voiceTrack != null) {
      return;
    }

    try {
      stream = await navigator.mediaDevices.getUserMedia({
        'video': false,
        'audio': true,
      });
      voiceTrack = stream?.getAudioTracks().first;
      voiceTrack?.enabled = false;
      streams.add(stream!);
    } catch (err) {
      logError('calls: unable to get media device: $err');
    }
  }

  Future<void> newConnection() async {
    final client = NetworkManager.getClient(serverUrl);
    final credentials = await getServerCredentials(serverUrl);

    ws = WebSocketClient(serverUrl, client.getWebSocketUrl(), credentials?.token);

    await ws?.initialize();

    if (hasMicPermission) {
      await initializeVoiceTrack();
    }

    disconnect([Error? err]) {
      if (isClosed) {
        return;
      }
      isClosed = true;

      ws?.send('leave');
      ws?.close();
      rtcMonitor?.stop();

      onCallEnd?.cancel();
      audioDeviceChanged?.cancel();
      wiredHeadsetEvent?.cancel();

      streams.forEach((s) {
        s.getTracks().forEach((track) {
          track.stop();
        });
      });

      peer?.destroy();
      peer = null;
      InCallManager.stop();

      if (Platform.isAndroid) {
        foregroundServiceStop();
      }

      if (closeCb != null) {
        closeCb(err);
      }
    }

    onCallEnd = EventChannel('WebsocketEvents.CALLS_CALL_END').receiveBroadcastStream().listen((event) {
      if (event['channelId'] == channelId) {
        disconnect();
      }
    });

    mute() {
      if (peer == null || voiceTrack == null) {
        return;
      }

      try {
        if (voiceTrackAdded) {
          peer?.replaceTrack(voiceTrack!.id, null);
        }
      } catch (e) {
        logError('calls: from RTCPeer, error on mute: $e');
        return;
      }

      voiceTrack?.enabled = false;
      ws?.send('mute');
    }

    unmute() {
      if (peer == null || voiceTrack == null) {
        return;
      }

      rtcMonitor?.clearCache();

      try {
        if (voiceTrackAdded) {
          peer?.replaceTrack(voiceTrack!.id, voiceTrack);
        } else {
          peer?.addStream(stream!);
          voiceTrackAdded = true;
        }
      } catch (e) {
        logError('calls: from RTCPeer, error on unmute: $e');
        return;
      }

      voiceTrack?.enabled = true;
      ws?.send('unmute');
    }

    raiseHand() {
      ws?.send('raise_hand');
    }

    unraiseHand() {
      ws?.send('unraise_hand');
    }

    sendReaction(String emoji) {
      ws?.send('react', {
        'data': jsonEncode(emoji),
      });
    }

    ws?.on('error', (err) {
      logDebug('calls: ws error $err');
      if (err == wsReconnectionTimeoutErr) {
        disconnect();
      }
    });

    ws?.on('close', (event) {
      logDebug('calls: ws close, code: ${event?.code}, reason: ${event?.reason}, message: ${event?.message}');
    });

    ws?.on('open', (originalConnID, prevConnID, isReconnect) {
      if (isReconnect) {
        logDebug('calls: ws reconnect, sending reconnect msg');
        ws?.send('reconnect', {
          'channelID': channelId,
          'originalConnID': originalConnID,
          'prevConnID': prevConnID,
        });
      } else {
        logDebug('calls: ws open, sending join msg');
        ws?.send('join', {
          'channelID': channelId,
          'title': title,
          'threadID': rootId,
        });
      }
    });

    ws?.on('join', () async {
      logDebug('calls: join ack received, initializing connection');
      CallConfig config;
      try {
        config = await client.getCallsConfig();
      } catch (err) {
        logError('calls: fetching calls config: ${getFullErrorMessage(err)}');
        return;
      }

      List<RTCIceServer> iceConfigs = getICEServersConfigs(config);
      if (config.NeedsTURNCredentials) {
        try {
          iceConfigs.addAll(await client.genTURNCredentials());
        } catch (err) {
          logWarning('calls: failed to fetch TURN credentials: ${getFullErrorMessage(err)}');
        }
      }

      InCallManager.start();
      InCallManager.stopProximitySensor();

      bool btInitialized = false;
      bool speakerInitialized = false;

      if (Platform.isAndroid) {
        audioDeviceChanged = EventChannel('onAudioDeviceChanged').receiveBroadcastStream().listen((data) {
          final info = AudioDeviceInfo.fromJson(jsonDecode(data));
          setAudioDeviceInfo(info);
          logDebug('calls: AudioDeviceChanged, info: $info');

          if (!btInitialized) {
            if (info.availableAudioDeviceList.contains(AudioDevice.Bluetooth)) {
              setPreferredAudioRoute(AudioDevice.Bluetooth);
              btInitialized = true;
            } else if (!speakerInitialized) {
              setPreferredAudioRoute(AudioDevice.Speakerphone);
              speakerInitialized = true;
            }
          }
        });

        await foregroundServiceStart();
      }

      if (Platform.isIOS) {
        wiredHeadsetEvent = EventChannel('WiredHeadset').receiveBroadcastStream().listen((data) {
          logDebug('calls: WiredHeadset plugged in, data: $data');
          if (data['isPlugged']) {
            setSpeakerphoneOn(false);
          }
        });

        final report = await InCallManager.getIsWiredHeadsetPluggedIn();
        setSpeakerphoneOn(!report.isWiredHeadsetPluggedIn);
      }

      peer = RTCPeer(
        iceServers: iceConfigs ?? [],
        logger: logger,
        webrtc: {
          'MediaStream': MediaStream,
          'RTCPeerConnection': RTCPeerConnection,
        },
      );

      rtcMonitor = RTCMonitor(
        peer: peer!,
        logger: logger,
        monitorInterval: rtcMonitorInterval,
      );
      rtcMonitor?.on('mos', processMeanOpinionScore);

      peer?.on('offer', (sdp) {
        logDebug('calls: local offer, sending: ${jsonEncode(sdp)}');
        ws?.send('sdp', {
          'data': deflate(jsonEncode(sdp)),
        }, true);
      });

      peer?.on('answer', (sdp) {
        logDebug('calls: local answer, sending: ${jsonEncode(sdp)}');
        ws?.send('sdp', {
          'data': deflate(jsonEncode(sdp)),
        }, true);
      });

      peer?.on('candidate', (candidate) {
        logDebug('calls: local candidate: ${jsonEncode(candidate)}');
        ws?.send('ice', {
          'data': jsonEncode(candidate),
        });
      });

      peer?.on('error', (err) {
        logError('calls: peer error: $err');
        if (!isClosed) {
          disconnect();
        }
      });

      peer?.on('stream', (remoteStream) {
        logDebug('calls: new remote stream received ${remoteStream.id}');
        for (var track in remoteStream.getTracks()) {
          logDebug('calls: remote track ${track.id}');
        }

        streams.add(remoteStream);
        if (remoteStream.getVideoTracks().isNotEmpty) {
          setScreenShareUrl(remoteStream.toUrl());
        }
      });

      peer?.on('close', () {
        logDebug('calls: peer closed');
        if (!isClosed) {
          disconnect();
        }
      });
    });

    ws?.on('message', (data) {
      final msg = jsonDecode(data);
      if (msg == null) {
        return;
      }
      if (msg['type'] != 'ping') {
        logDebug('calls: remote signal $data');
      }
      if (msg['type'] == 'answer' || msg['type'] == 'candidate' || msg['type'] == 'offer') {
        peer?.signal(data);
      }
    });

    Future<void> waitForPeerConnection() async {
      void waitForReadyImpl(Function callback, Function fail, int timeout) {
        if (timeout <= 0) {
          fail('timed out waiting for peer connection');
          return;
        }
        Timer(Duration(milliseconds: 200), () {
          if (peer?.connected ?? false) {
            rtcMonitor?.start();
            callback();
          } else {
            waitForReadyImpl(callback, fail, timeout - 200);
          }
        });
      }

      return Future<void>((resolve, reject) {
        waitForReadyImpl(resolve, reject, peerConnectTimeout);
      });
    }

    final connection = CallsConnection(
      disconnect: disconnect,
      mute: mute,
      unmute: unmute,
      waitForPeerConnection: waitForPeerConnection,
      raiseHand: raiseHand,
      unraiseHand: unraiseHand,
      sendReaction: sendReaction,
      initializeVoiceTrack: initializeVoiceTrack,
    );

    return connection;
  }
}
