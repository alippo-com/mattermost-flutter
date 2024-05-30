// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:mattermost_flutter/calls/client/rest/client_calls.dart';
import 'package:mattermost_flutter/client/rest/plugins/client_plugins.dart';

import 'apps/client_apps.dart';
import 'base/client_base.dart';
import 'categories/client_categories.dart';
import 'channels/client_channels.dart';
import 'emojis/client_emojis.dart';
import 'files/client_files.dart';
import 'general/client_general.dart';
import 'groups/client_groups.dart';
import 'integrations/client_integrations.dart';
import 'nps/client_nps.dart';
import 'posts/client_posts.dart';
import 'preferences/client_preferences.dart';
import 'teams/client_teams.dart';
import 'threads/client_threads.dart';
import 'tos/client_tos.dart';
import 'users/client_users.dart';

import 'package:mattermost_flutter/types/api_client_interface.dart';

class Client extends ClientBase
    with
        ClientApps,
        ClientCategories,
        ClientChannels,
        ClientEmojis,
        ClientFiles,
        ClientGeneral,
        ClientGroups,
        ClientIntegrations,
        ClientPosts,
        ClientPreferences,
        ClientTeams,
        ClientThreads,
        ClientTos,
        ClientUsers,
        ClientCalls,
        ClientPlugins,
        ClientNPS {
  Client(APIClientInterface apiClient, String serverUrl, {String? bearerToken, String? csrfToken})
      : super(apiClient, serverUrl, bearerToken: bearerToken, csrfToken: csrfToken);
}

const DEFAULT_LIMIT_AFTER = ...; // define the appropriate value
const DEFAULT_LIMIT_BEFORE = ...; // define the appropriate value
const HEADER_X_VERSION_ID = ...; // define the appropriate value

export 'client.dart'; // Adjust the path if necessary