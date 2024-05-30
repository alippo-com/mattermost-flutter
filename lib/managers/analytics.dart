// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:device_info/device_info.dart';
import 'package:mattermost_flutter/assets/config.dart';
import 'package:mattermost_flutter/utils/helpers.dart';
import 'package:mattermost_flutter/utils/user.dart';

class Analytics {
  RudderClient? analytics;
  dynamic context;
  String? diagnosticId;

  String? userRoles;
  String userId = '';
  Map<String, int> tracker = {
    'initialLoad': 0,
    'channelSwitch': 0,
    'teamSwitch': 0,
  };

  Future<void> init(ClientConfig config) async {
    if (LocalConfig.rudderApiKey != null) {
      // Rudder stack has been temporarily removed
      // this.analytics = require('@rudderstack/rudder-sdk-react-native').default;
    }

    if (analytics != null) {
      final size = MediaQueryData.fromWindow(WidgetsBinding.instance.window).size;
      diagnosticId = config.diagnosticId;

      if (diagnosticId != null) {
        await analytics!.setup(LocalConfig.rudderApiKey, {
          'dataPlaneUrl': 'https://pdat.matterlytics.com',
          'recordScreenViews': true,
          'flushQueueSize': 20,
        });

        context = {
          'app': {
            'version': await DeviceInfoPlugin().version,
            'build': await DeviceInfoPlugin().buildNumber,
          },
          'device': {
            'dimensions': {
              'height': size.height,
              'width': size.width,
            },
            'isTablet': isTablet(),
            'os': await DeviceInfoPlugin().systemVersion,
          },
          'ip': '0.0.0.0',
          'server': config.version,
        };

        analytics!.identify(
          diagnosticId,
          context,
        );
      } else {
        analytics!.reset();
      }
    }

    return analytics;
  }

  Future<void> reset() async {
    userId = '';
    userRoles = null;
    if (analytics != null) {
      await analytics!.reset();
    }
  }

  void setUserId(String userId) {
    this.userId = userId;
  }

  void setUserRoles(String roles) {
    userRoles = roles;
  }

  void trackEvent(String category, String event, [dynamic props]) {
    if (analytics == null) {
      return;
    }

    final properties = {
      'category': category,
      'type': event,
      'user_actual_role': userRoles != null && isSystemAdmin(userRoles!) ? 'system_admin, system_user' : 'system_user',
      'user_actual_id': userId,
      ...?props,
    };
    final options = {
      'context': context,
      'anonymousId': '00000000000000000000000000',
    };

    analytics!.track(event, properties, options);
  }

  void recordTime(String screenName, String category, String userId) {
    if (analytics != null) {
      final startTime = tracker[category];
      tracker[category] = 0;
      analytics!.screen(
        screenName,
        {
          'userId': diagnosticId,
          'context': context,
          'properties': {
            'user_actual_id': userId,
            'time': DateTime.now().millisecondsSinceEpoch - startTime!,
          },
        },
      );
    }
  }

  void trackAPI(String event, [dynamic props]) {
    if (analytics == null) {
      return;
    }

    trackEvent('api', event, props);
  }

  void trackCommand(String event, String command, [String? errorMessage]) {
    if (analytics == null) {
      return;
    }

    final sanitizedCommand = sanitizeCommand(command);
    final props = errorMessage != null
        ? {'command': sanitizedCommand, 'error': errorMessage}
        : {'command': sanitizedCommand};

    trackEvent('command', event, props);
  }

  void trackAction(String event, [dynamic props]) {
    if (analytics == null) {
      return;
    }
    trackEvent('action', event, props);
  }

  String sanitizeCommand(String userInput) {
    final commandList = ['agenda', 'autolink', 'away', 'bot-server', 'code', 'collapse',
      'dnd', 'echo', 'expand', 'export', 'giphy', 'github', 'groupmsg', 'header', 'help',
      'invite', 'invite_people', 'jira', 'jitsi', 'join', 'kick', 'leave', 'logout', 'me',
      'msg', 'mute', 'nc', 'offline', 'online', 'open', 'poll', 'poll2', 'post-mortem',
      'purpose', 'recommend', 'remove', 'rename', 'search', 'settings', 'shortcuts',
      'shrug', 'standup', 'todo', 'wrangler', 'zoom'];
    final index = userInput.indexOf(' ');
    if (index == -1) {
      return userInput[0];
    }
    final command = userInput.substring(1, index);
    if (commandList.contains(command)) {
      return command;
    }
    return 'custom_command';
  }
}

final clientMap = <String, Analytics>{};

Analytics create(String serverUrl) {
  var client = clientMap[serverUrl];

  if (client != null) {
    return client;
  }

  client = Analytics();
  clientMap[serverUrl] = client;
  return client;
}

Analytics? get(String serverUrl) {
  return clientMap[serverUrl];
}

void invalidate(String serverUrl) {
  clientMap.remove(serverUrl);
}

final analyticsService = {
  'create': create,
  'get': get,
  'invalidate': invalidate,
};