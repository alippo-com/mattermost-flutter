
// Converted Dart code from TypeScript

import 'package:mattermost_flutter/utils/calls.dart';
import 'package:flutter/material.dart';
import 'package:mattermost_flutter/constants/calls.dart';
import 'package:mattermost_flutter/constants/push_notification.dart';
import 'package:mattermost_flutter/utils/helpers.dart';
import 'package:mattermost_flutter/utils/user.dart';
import 'package:mattermost_flutter/types/calls.dart';
import 'package:mattermost_flutter/types/models.dart';
import 'package:intl/intl.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

const callsMessageRegex = r'^​.* is inviting you to a call$';

List<CallSession> sortSessions(String locale, String teammateNameDisplay, Map<String, CallSession>? sessions, [String? presenterID]) {
  if (sessions == null) {
    return [];
  }

  var sessns = sessions.values.toList();

  sessns.sort(sortByState(presenterID));
  sessns.sort(sortByName(locale, teammateNameDisplay));

  return sessns;
}

int Function(CallSession, CallSession) sortByName(String locale, String teammateNameDisplay) {
  return (a, b) {
    var nameA = displayUsername(a.userModel, locale, teammateNameDisplay);
    var nameB = displayUsername(b.userModel, locale, teammateNameDisplay);
    return nameA.compareTo(nameB);
  };
}

int Function(CallSession, CallSession) sortByState([String? presenterID]) {
  return (a, b) {
    if (a.sessionId == presenterID) {
      return -1;
    } else if (b.sessionId == presenterID) {
      return 1;
    }

    if (a.raisedHand && !b.raisedHand) {
      return -1;
    } else if (b.raisedHand && !a.raisedHand) {
      return 1;
    } else if (a.raisedHand && b.raisedHand) {
      return a.raisedHand!.compareTo(b.raisedHand!);
    }

    if (!a.muted && b.muted) {
      return -1;
    } else if (!b.muted && a.muted) {
      return 1;
    }

    return 0;
  };
}

List<CallSession> getHandsRaised(Map<String, CallSession> sessions) {
  return sessions.values.where((s) => s.raisedHand).toList();
}

List<String> getHandsRaisedNames(List<CallSession> sessions, String sessionId, String locale, String teammateNameDisplay, Intl intl) {
  return sessions
      .where((s) => s.raisedHand != null)
      .map((s) {
        if (s.sessionId == sessionId) {
          return intl.message('You', name: 'mobile.calls_you_2');
        }
        return displayUsername(s.userModel, locale, teammateNameDisplay);
      })
      .toList();
}

bool isSupportedServerCalls([String? serverVersion]) {
  if (serverVersion != null) {
    return isMinimumServerVersion(
      serverVersion,
      Calls.RequiredServer.MAJOR_VERSION,
      Calls.RequiredServer.MIN_VERSION,
      Calls.RequiredServer.PATCH_VERSION,
    );
  }
  return false;
}

bool isMultiSessionSupported(CallsVersion callsVersion) {
  return isMinimumServerVersion(
    callsVersion.version,
    Calls.MultiSessionCallsVersion.MAJOR_VERSION,
    Calls.MultiSessionCallsVersion.MIN_VERSION,
    Calls.MultiSessionCallsVersion.PATCH_VERSION,
  );
}

bool isHostControlsAllowed(CallsConfigState config) {
  return config.HostControlsAllowed;
}

bool isCallsCustomMessage(PostModel post) {
  return post.type == Post.POST_TYPES.CUSTOM_CALLS;
}

bool idsAreEqual(List<String> a, List<String> b) {
  if (a.length != b.length) {
    return false;
  }

  var obj = {for (var id in a) id: true};

  for (var id in b) {
    if (!obj.containsKey(id)) {
      return false;
    }
  }
  return true;
}

void errorAlert(String error, Intl intl) {
  showDialog(
    context: navigatorKey.currentContext!,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(intl.message('Error', name: 'mobile.calls_error_title')),
        content: Text(intl.message('Error: {error}', name: 'mobile.calls_error_message', args: {'error': error})),
        actions: <Widget>[
          TextButton(
            child: Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

List<RTCIceServer> getICEServersConfigs(CallsConfig config) {
  if (config.ICEServersConfigs.isNotEmpty) {
    return config.ICEServersConfigs;
  }

  if (config.ICEServers.isNotEmpty) {
    return [RTCIceServer(urls: config.ICEServers)];
  }

  return [];
}

CallsTheme makeCallsTheme(Theme theme) {
  var baseColorRGB = makeCallsBaseAndBadgeRGB(theme.sidebarBg);
  var badgeBgRGB = makeCallsBaseAndBadgeRGB(theme.sidebarBg);

  return CallsTheme(
    callsBg: rgbToCSS(baseColorRGB),
    callsBgRgb: '${baseColorRGB.r},${baseColorRGB.g},${baseColorRGB.b}',
    callsBadgeBg: rgbToCSS(badgeBgRGB),
  );
}

List<String> userIds<T extends HasUserId>(List<T> hasUserId) {
  var ids = <String>[];
  var seen = <String, bool>{};
  for (var p in hasUserId) {
    if (!seen.containsKey(p.userId)) {
      ids.add(p.userId);
      seen[p.userId] = true;
    }
  }
  return ids;
}

Map<String, CallSession> fillUserModels(Map<String, CallSession> sessions, List<UserModel> models) {
  var idToModel = {for (var model in models) model.id: model};
  var next = {...sessions};
  for (var participant in next.values) {
    participant.userModel = idToModel[participant.userId];
  }
  return sessions;
}

bool isCallsStartedMessage(NotificationData? payload) {
  if (payload?.subType == NOTIFICATION_SUB_TYPE.CALLS) {
    return true;
  }

  return payload?.message == "You've been invited to a call" || RegExp(callsMessageRegex).hasMatch(payload?.message ?? '');
}

bool hasCaptions([Map<String, dynamic>? postProps]) {
  return postProps != null && postProps['captions'] != null && postProps['captions'].isNotEmpty;
}

Map<String, dynamic> getTranscriptionUri(String serverUrl, [Map<String, dynamic>? postProps]) {
  if (postProps == null || postProps['captions'] == null || postProps['captions'].isEmpty) {
    return {
      'tracks': null,
      'selected': {'type': 'disabled'},
    };
  }

  var tracks = postProps['captions']
      .map((t) => {
            'title': t['title'],
            'language': t['language'],
            'type': 'vtt',
            'uri': buildFileUrl(serverUrl, t['file_id']),
          })
      .toList();

  return {
    'tracks': tracks,
    'selected': {'type': 'index', 'value': 0},
  };
}
