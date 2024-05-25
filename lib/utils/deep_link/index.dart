// Converted Dart Code

import 'package:path_to_regexp/path_to_regexp.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mattermost_flutter/actions/remote/channel.dart';
import 'package:mattermost_flutter/actions/remote/permalink.dart';
import 'package:mattermost_flutter/actions/remote/user.dart';
import 'package:mattermost_flutter/constants/deep_linking.dart';
import 'package:mattermost_flutter/constants.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/database/manager.dart';
import 'package:mattermost_flutter/i18n.dart';
import 'package:mattermost_flutter/managers/websocket_manager.dart';
import 'package:mattermost_flutter/queries/app/servers.dart';
import 'package:mattermost_flutter/queries/servers/user.dart';
import 'package:mattermost_flutter/screens/navigation.dart';
import 'package:mattermost_flutter/store/ephemeral_store.dart';
import 'package:mattermost_flutter/store/navigation_store.dart';
import 'package:mattermost_flutter/utils/draft.dart';
import 'package:mattermost_flutter/utils/log.dart';
import 'package:mattermost_flutter/utils/markdown.dart';
import 'package:mattermost_flutter/utils/server.dart';
import 'package:mattermost_flutter/utils/url/path.dart';
import 'package:mattermost_flutter/utils/url.dart';
import 'package:mattermost_flutter/types/launch.dart';
import 'package:mattermost_flutter/types/screens/navigation.dart';

const deepLinkScreens = [Screens.HOME, Screens.CHANNEL, Screens.GLOBAL_THREADS, Screens.THREAD];

Future<Map<String, bool>> handleDeepLink(String deepLinkUrl, {Intl? intlShape, String? location}) async {
  try {
    final parsed = parseDeepLink(deepLinkUrl);
    if (parsed.type == DeepLink.Invalid || parsed.data == null || parsed.data.serverUrl.isEmpty) {
      return {'error': true};
    }

    final currentServerUrl = await getActiveServerUrl();
    final existingServerUrl = DatabaseManager.searchUrl(parsed.data.serverUrl);

    // After checking the server for http & https then we add it
    if (existingServerUrl.isEmpty) {
      final theme = EphemeralStore.theme ?? getDefaultThemeByAppearance();
      addNewServer(theme, parsed.data.serverUrl, null, parsed);
      return {'error': false};
    }

    if (existingServerUrl != currentServerUrl && NavigationStore.getVisibleScreen().isNotEmpty) {
      await dismissAllModalsAndPopToRoot();
      DatabaseManager.setActiveServerDatabase(existingServerUrl);
      WebsocketManager.initializeClient(existingServerUrl);
      await NavigationStore.waitUntilScreenHasLoaded(Screens.HOME);
    }

    final database = DatabaseManager.getServerDatabaseAndOperator(existingServerUrl).database;
    final currentUser = await getCurrentUser(database);
    final locale = currentUser?.locale ?? DEFAULT_LOCALE;
    final intl = intlShape ?? Intl(locale, getTranslations(locale));

    switch (parsed.type) {
      case DeepLink.Channel:
        final deepLinkData = parsed.data as DeepLinkChannel;
        switchToChannelByName(existingServerUrl, deepLinkData.channelName, deepLinkData.teamName, errorBadChannel, intl);
        break;
      case DeepLink.DirectMessage:
        final deepLinkData = parsed.data as DeepLinkDM;
        final userIds = await queryUsersByUsername(database, [deepLinkData.userName]).fetchIds();
        var userId = userIds.isNotEmpty ? userIds[0] : null;
        if (userId == null) {
          final users = await fetchUsersByUsernames(existingServerUrl, [deepLinkData.userName], false)?.users;
          if (users?.isNotEmpty == true) {
            userId = users[0].id;
          }
        }

        if (userId != null) {
          makeDirectChannel(existingServerUrl, userId, '', true);
        } else {
          errorUnkownUser(intl);
        }
        break;
      case DeepLink.GroupMessage:
        final deepLinkData = parsed.data as DeepLinkGM;
        switchToChannelByName(existingServerUrl, deepLinkData.channelName, deepLinkData.teamName, errorBadChannel, intl);
        break;
      case DeepLink.Permalink:
        final deepLinkData = parsed.data as DeepLinkPermalink;
        if (NavigationStore.hasModalsOpened() || !deepLinkScreens.contains(NavigationStore.getVisibleScreen())) {
          await dismissAllModalsAndPopToRoot();
        }
        showPermalink(existingServerUrl, deepLinkData.teamName, deepLinkData.postId);
        break;
    }
    return {'error': false};
  } catch (error) {
    logError('Failed to open channel from deeplink', error, location);
    return {'error': true};
  }
}

final CHANNEL_PATH = r':serverUrl(.*)/:teamName(${TEAM_NAME_PATH_PATTERN})/:path(channels|messages)/:identifier(${IDENTIFIER_PATH_PATTERN})';
final matchChannelDeeplink = match<ChannelPathParams>(CHANNEL_PATH);

final PERMALINK_PATH = r':serverUrl(.*)/:teamName(${TEAM_NAME_PATH_PATTERN})/pl/:postId(${ID_PATH_PATTERN})';
final matchPermalinkDeeplink = match<PermalinkPathParams>(PERMALINK_PATH);

DeepLinkWithData parseDeepLink(String deepLinkUrl) {
  try {
    final url = removeProtocol(deepLinkUrl);

    final channelMatch = matchChannelDeeplink(url);
    if (channelMatch != null) {
      final serverUrl = channelMatch.params.serverUrl;
      final teamName = channelMatch.params.teamName;
      final path = channelMatch.params.path;
      final identifier = channelMatch.params.identifier;

      if (path == 'channels') {
        return DeepLinkWithData(type: DeepLink.Channel, url: deepLinkUrl, data: DeepLinkChannel(serverUrl, teamName, identifier));
      }

      if (path == 'messages') {
        if (identifier.startsWith('@')) {
          return DeepLinkWithData(type: DeepLink.DirectMessage, url: deepLinkUrl, data: DeepLinkDM(serverUrl, teamName, identifier.substring(1)));
        }

        return DeepLinkWithData(type: DeepLink.GroupMessage, url: deepLinkUrl, data: DeepLinkGM(serverUrl, teamName, identifier));
      }
    }

    final permalinkMatch = matchPermalinkDeeplink(url);
    if (permalinkMatch != null) {
      final serverUrl = permalinkMatch.params.serverUrl;
      final teamName = permalinkMatch.params.teamName;
      final postId = permalinkMatch.params.postId;
      return DeepLinkWithData(type: DeepLink.Permalink, url: deepLinkUrl, data: DeepLinkPermalink(serverUrl, teamName, postId));
    }
  } catch (err) {
    // do nothing just return invalid deeplink
  }

  return DeepLinkWithData(type: DeepLink.Invalid, url: deepLinkUrl);
}

DeepLinkWithData? matchDeepLink(String url, {String? serverURL, String? siteURL}) {
  if (url.isEmpty || (serverURL == null && siteURL == null)) {
    return null;
  }

  var urlToMatch = url;
  final urlBase = serverURL ?? siteURL ?? '';
  final parsedUrl = Uri.parse(url);

  if (parsedUrl.scheme.isEmpty) {
    // If url doesn't contain site or server URL, tack it on.
    // e.g. <jump to convo> URLs from autolink plugin.
    final deepLinkMatch = RegExp(RegExp.escape(urlBase)).firstMatch(url);
    if (deepLinkMatch == null) {
      urlToMatch = urlBase + url;
    }
  }

  final parsed = parseDeepLink(urlToMatch);

  if (parsed.type == DeepLinkType.Invalid) {
    return null;
  }

  return parsed;
}

LaunchProps getLaunchPropsFromDeepLink(String deepLinkUrl, {bool coldStart = false}) {
  final parsed = parseDeepLink(deepLinkUrl);
  final launchProps = LaunchProps(launchType: Launch.DeepLink, coldStart: coldStart);

  switch (parsed.type) {
    case DeepLink.Invalid:
      launchProps.launchError = true;
      break;
    default:
      launchProps.extra = parsed;
      break;
  }

  return launchProps;
}

void alertInvalidDeepLink(Intl intl) {
  final message = {
    'id': t('mobile.deep_link.invalid'),
    'defaultMessage': 'This link you are trying to open is invalid.',
  };

  alertErrorWithFallback(intl, {}, message);
}
