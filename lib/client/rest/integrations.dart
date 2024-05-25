
// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:mattermost_flutter/utils/helpers.dart';
import 'constants.dart';

import '../base.dart';

abstract class ClientIntegrationsMix {
  Future<List<Command>> getCommandsList(String teamId);
  Future<List<AutocompleteSuggestion>> getCommandAutocompleteSuggestionsList(String userInput, String teamId, String channelId, {String rootId});
  Future<List<Command>> getAutocompleteCommandsList(String teamId, {int page = 0, int perPage = PER_PAGE_DEFAULT});
  Future<CommandResponse> executeCommand(String command, {CommandArgs commandArgs});
  Future<Command> addCommand(Command command);
  Future<dynamic> submitInteractiveDialog(DialogSubmission data);
}

mixin ClientIntegrations<T extends ClientBase> on ClientBase {
  Future<List<Command>> getCommandsList(String teamId) async {
    return doFetch<List<Command>>(
      '${getCommandsRoute()}?team_id=$teamId',
      method: 'get',
    );
  }

  Future<List<AutocompleteSuggestion>> getCommandAutocompleteSuggestionsList(String userInput, String teamId, String channelId, {String rootId}) async {
    return doFetch<List<AutocompleteSuggestion>>(
      '${getTeamRoute(teamId)}/commands/autocomplete_suggestions${buildQueryString({'user_input': userInput, 'team_id': teamId, 'channel_id': channelId, 'root_id': rootId})}',
      method: 'get',
    );
  }

  Future<List<Command>> getAutocompleteCommandsList(String teamId, {int page = 0, int perPage = PER_PAGE_DEFAULT}) async {
    return doFetch<List<Command>>(
      '${getTeamRoute(teamId)}/commands/autocomplete${buildQueryString({'page': page, 'per_page': perPage})}',
      method: 'get',
    );
  }

  Future<CommandResponse> executeCommand(String command, {CommandArgs commandArgs = const {}}) async {
    analytics?.trackAPI('api_integrations_used');

    return doFetch<CommandResponse>(
      '${getCommandsRoute()}/execute',
      method: 'post',
      body: {'command': command, ...commandArgs},
    );
  }

  Future<Command> addCommand(Command command) async {
    analytics?.trackAPI('api_integrations_created');

    return doFetch<Command>(
      '${getCommandsRoute()}',
      method: 'post',
      body: command,
    );
  }

  Future<dynamic> submitInteractiveDialog(DialogSubmission data) async {
    analytics?.trackAPI('api_interactive_messages_dialog_submitted');
    return doFetch<dynamic>(
      '${urlVersion}/actions/dialogs/submit',
      method: 'post',
      body: data,
    );
  }
}
