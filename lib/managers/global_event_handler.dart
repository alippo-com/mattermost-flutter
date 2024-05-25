import 'dart:async';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';

import 'package:mattermost_flutter/actions/remote/channel.dart';
import 'package:mattermost_flutter/constants/device.dart';
import 'package:mattermost_flutter/constants/events.dart';
import 'package:mattermost_flutter/constants/sso.dart';
import 'package:mattermost_flutter/constants/supported_server.dart';
import 'package:mattermost_flutter/database/manager.dart';
import 'package:mattermost_flutter/i18n/i18n.dart';
import 'package:mattermost_flutter/init/credentials.dart';
import 'package:mattermost_flutter/managers/analytics.dart';
import 'package:mattermost_flutter/queries/app/servers.dart';
import 'package:mattermost_flutter/queries/servers/channel.dart';
import 'package:mattermost_flutter/queries/servers/system.dart';
import 'package:mattermost_flutter/queries/servers/team.dart';
import 'package:mattermost_flutter/screens/navigation.dart';
import 'package:mattermost_flutter/utils/deep_link.dart';
import 'package:mattermost_flutter/utils/general.dart';
import 'package:mattermost_flutter/utils/error_handling.dart';

class GlobalEventHandler {
  JsAndNativeErrorHandler? javascriptAndNativeErrorHandler;

  GlobalEventHandler() {
    EventChannel(Events.SERVER_VERSION_CHANGED).receiveBroadcastStream().listen(onServerVersionChanged);
    EventChannel(Events.CONFIG_CHANGED).receiveBroadcastStream().listen(onServerConfigChanged);
    EventChannel('SplitViewChanged').receiveBroadcastStream().listen(onSplitViewChanged);
    EventChannel('url').receiveBroadcastStream().listen(onDeepLink);
  }

  void init() {
    javascriptAndNativeErrorHandler = JsAndNativeErrorHandler();
    javascriptAndNativeErrorHandler?.initializeErrorHandling();
  }

  Future<void> configureAnalytics(String serverUrl, [ClientConfig? config]) async {
    if (serverUrl.isNotEmpty && config?.diagnosticsEnabled == 'true' && config?.diagnosticId != null && LocalConfig.rudderApiKey != null) {
      var client = AnalyticsManager.get(serverUrl);
      if (client == null) {
        client = AnalyticsManager.create(serverUrl);
      }

      await client.init(config);
    }
  }

  Future<void> onDeepLink(dynamic event) async {
    final url = event['url'];
    if (url?.startsWith(Sso.REDIRECT_URL_SCHEME) == true || url?.startsWith(Sso.REDIRECT_URL_SCHEME_DEV) == true) {
      return;
    }

    if (url != null) {
      final error = await handleDeepLink(url);
      if (error != null) {
        alertInvalidDeepLink(getIntlShape(DEFAULT_LOCALE));
      }
    }
  }

  Future<void> onServerConfigChanged(dynamic event) async {
    final serverUrl = event['serverUrl'];
    final config = event['config'];
    if (serverUrl != null && config != null) {
      await configureAnalytics(serverUrl, config);
    }
  }

  Future<void> onServerVersionChanged(dynamic event) async {
    final serverUrl = event['serverUrl'];
    final serverVersion = event['serverVersion'];
    final match = RegExp(r'^[0-9]*.[0-9]*.[0-9]*(-[a-zA-Z0-9.-]*)?').firstMatch(serverVersion ?? '');
    final version = match?.group(0);
    final locale = DEFAULT_LOCALE;
    final translations = getTranslations(locale);

    if (version != null && semver.valid(version) && semver.lt(version, MIN_REQUIRED_VERSION)) {
      showDialog(
        context: BuildContext,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(translations[t('mobile.server_upgrade.title')]),
            content: Text(translations[t('mobile.server_upgrade.description')]),
            actions: <Widget>[
              TextButton(
                child: Text(translations[t('mobile.server_upgrade.button')]),
                onPressed: () {
                  serverUpgradeNeeded(serverUrl);
                },
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> onSplitViewChanged(dynamic result) async {
    final isTablet = result['isTablet'];
    if (isTablet != null && Device.IS_TABLET != isTablet) {
      Device.IS_TABLET = isTablet;
      final serverUrl = await getActiveServerUrl();
      if (serverUrl != null && isTablet) {
        try {
          final database = DatabaseManager.getServerDatabaseAndOperator(serverUrl).database;
          final commonValues = await getCommonSystemValues(database);
          final currentChannelId = commonValues['currentChannelId'];
          final currentTeamId = commonValues['currentTeamId'];
          if (currentTeamId != null && currentChannelId == null) {
            var channelId = '';
            final teamChannelHistory = await getTeamChannelHistory(database, currentTeamId);
            if (teamChannelHistory.isNotEmpty) {
              channelId = teamChannelHistory[0];
            } else {
              final defaultChannel = await queryTeamDefaultChannel(database, currentTeamId).fetch();
              if (defaultChannel.isNotEmpty) {
                channelId = defaultChannel[0].id;
              }
            }

            if (channelId.isNotEmpty) {
              switchToChannelById(serverUrl, channelId);
            }
          }
        } catch (e) {
          // Handle error
        }
      }
      setScreensOrientation(isTablet);
    }
  }

  Future<void> serverUpgradeNeeded(String serverUrl) async {
    final credentials = await getServerCredentials(serverUrl);
    if (credentials != null) {
      EventChannel(Events.SERVER_LOGOUT).receiveBroadcastStream().listen((event) {
        // Handle server logout
      });
    }
  }
}

final globalEventHandler = GlobalEventHandler();
