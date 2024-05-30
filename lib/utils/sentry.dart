
// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'dart:async';
import 'dart:io';

import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:mattermost_flutter/assets/config.dart';
import 'package:mattermost_flutter/client/rest/error.dart';
import 'package:mattermost_flutter/database/manager.dart';
import 'package:mattermost_flutter/queries/servers/user.dart';
import 'package:mattermost_flutter/utils/errors.dart';
import 'package:mattermost_flutter/utils/general.dart';

import 'log.dart';

const BREADCRUMB_UNCAUGHT_APP_ERROR = 'uncaught-app-error';
const BREADCRUMB_UNCAUGHT_NON_ERROR = 'uncaught-non-error';

SentryClient? sentry;

void initializeSentry() {
  if (!Config.sentryEnabled) {
    return;
  }

  if (sentry == null) {
    sentry = SentryClient(
      dsn: getDsn(),
      options: SentryOptions(
        environment: isBetaApp ? 'beta' : 'production',
        tracesSampleRate: isBetaApp ? 1.0 : 0.2,
        sampleRate: isBetaApp ? 1.0 : 0.2,
        attachStacktrace: isBetaApp,
      ),
    );
  }

  final dsn = getDsn();

  if (dsn.isEmpty) {
    logWarning('Sentry is enabled, but not configured on this platform');
    return;
  }

  final mmConfig = SentryOptions(
    environment: isBetaApp ? 'beta' : 'production',
    tracesSampleRate: isBetaApp ? 1.0 : 0.2,
    sampleRate: isBetaApp ? 1.0 : 0.2,
    attachStacktrace: isBetaApp,
  );

  final eventFilter = Config.sentryOptions?.severityLevelFilter?.toList() ?? [];
  final sentryOptions = SentryOptions.fromConfig(Config.sentryOptions);
  sentryOptions.severityLevelFilter = null;

  SentryFlutter.init(
    (options) {
      options.dsn = dsn;
      options.sendDefaultPii = false;
      options..mergeIn(mmConfig)..mergeIn(sentryOptions);
      options.enableCaptureFailedRequests = false;
      options.addIntegration(
        SentryFlutterIntegration(
          tracing: SentryFlutterTracing(
            routingInstrumentation: SentryFlutterNavigationInstrumentation(),
          ),
        ),
      );
      options.beforeSend = (event) {
        if (isBetaApp || (event?.level != null && eventFilter.contains(event.level))) {
          return event;
        }
        return null;
      };
    },
  );
}

String getDsn() {
  if (Platform.isAndroid) {
    return Config.sentryDsnAndroid;
  } else if (Platform.isIOS) {
    return Config.sentryDsnIos;
  }
  return '';
}

void captureException(dynamic error) {
  if (!Config.sentryEnabled) {
    return;
  }

  if (error == null) {
    logWarning('captureException called with missing arguments', error);
    return;
  }
  Sentry.captureException(error);
}

void captureJSException(dynamic error, bool isFatal) {
  if (!Config.sentryEnabled) {
    return;
  }

  if (error == null) {
    logWarning('captureJSException called with missing arguments', error);
    return;
  }

  if (error is ClientError) {
    captureClientErrorAsBreadcrumb(error, isFatal);
  } else {
    captureException(error);
  }
}

void captureClientErrorAsBreadcrumb(ClientError error, bool isFatal) {
  final isAppError = error.serverErrorId != null;
  final breadcrumb = Breadcrumb(
    category: isAppError ? BREADCRUMB_UNCAUGHT_APP_ERROR : BREADCRUMB_UNCAUGHT_NON_ERROR,
    data: {
      'isFatal': isFatal.toString(),
    },
    level: SentryLevel.warning,
    message: getFullErrorMessage(error),
  );

  if (breadcrumb.data != null) {
    if (error.serverErrorId != null) {
      breadcrumb.data!['server_error_id'] = error.serverErrorId;
    }

    if (error.statusCode != null) {
      breadcrumb.data!['status_code'] = error.statusCode;
    }

    final match = RegExp(r'^(?:https?:\/\/)[^/]+(\/.*)$').firstMatch(error.url);

    if (match != null && match.groupCount >= 1) {
      breadcrumb.data!['url'] = match.group(1);
    }
  }

  try {
    Sentry.addBreadcrumb(breadcrumb);
  } catch (e) {
    logWarning('Failed to capture breadcrumb of non-error', e);
  }
}

Future<Map<String, dynamic>> getUserContext(Database database) async {
  final currentUser = {
    'id': 'currentUserId',
    'locale': 'en',
    'roles': 'multi-server-test-role',
  };

  final user = await getCurrentUser(database);

  return {
    'userID': user?.id ?? currentUser['id'],
    'email': '',
    'username': '',
    'locale': user?.locale ?? currentUser['locale'],
    'roles': user?.roles ?? currentUser['roles'],
  };
}

Future<Map<String, dynamic>> getExtraContext(Database database) async {
  final context = {
    'config': {},
    'currentChannel': {},
    'currentTeam': {},
  };

  final config = await getConfig(database);
  if (config != null) {
    context['config'] = {
      'BuildDate': config.buildDate,
      'BuildEnterpriseReady': config.buildEnterpriseReady,
      'BuildHash': config.buildHash,
      'BuildHashEnterprise': config.buildHashEnterprise,
      'BuildNumber': config.buildNumber,
    };
  }

  return context;
}

Future<Map<String, dynamic>> getBuildTags(Database database) async {
  final tags = {
    'serverBuildHash': '',
    'serverBuildNumber': '',
  };

  final config = await getConfig(database);
  if (config != null) {
    tags['serverBuildHash'] = config.buildHash;
    tags['serverBuildNumber'] = config.buildNumber;
  }

  return tags;
}

Future<void> addSentryContext(String serverUrl) async {
  if (!Config.sentryEnabled || sentry == null) {
    return;
  }

  try {
    final database = DatabaseManager.getServerDatabaseAndOperator(serverUrl).database;
    final userContext = await getUserContext(database);
    sentry?.setUserContext(userContext);

    final buildContext = await getBuildTags(database);
    sentry?.setContext('App-Build Information', buildContext);

    final extraContext = await getExtraContext(database);
    sentry?.setContext('Server-Information', extraContext);
  } catch (e) {
    logError('addSentryContext for serverUrl $serverUrl', e);
  }
}
