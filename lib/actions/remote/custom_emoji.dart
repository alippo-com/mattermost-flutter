// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:mattermost_flutter/actions/remote/session.dart';
import 'package:mattermost_flutter/constants/general.dart';
import 'package:mattermost_flutter/constants/emoji.dart';
import 'package:mattermost_flutter/database/manager.dart';
import 'package:mattermost_flutter/helpers/api/general.dart';
import 'package:mattermost_flutter/managers/network_manager.dart';
import 'package:mattermost_flutter/queries/servers/custom_emoji.dart';
import 'package:mattermost_flutter/utils/errors.dart';
import 'package:mattermost_flutter/utils/log.dart';

Future<Map<String, dynamic>> fetchCustomEmojis(String serverUrl, {int page = 0, int perPage = General.PAGE_SIZE_DEFAULT, String sort = Emoji.SORT_BY_NAME}) async {
  try {
    final client = NetworkManager().getClient(serverUrl);
    final result = await DatabaseManager().getServerDatabaseAndOperator(serverUrl);
    final operator = result['operator'];

    final data = await client.getCustomEmojis(page, perPage, sort);
    await operator.handleCustomEmojis({
      'emojis': data,
      'prepareRecordsOnly': false,
    });

    return {'data': data};
  } catch (error) {
    logDebug('error on fetchCustomEmojis', getFullErrorMessage(error));
    forceLogoutIfNecessary(serverUrl, error);
    return {'error': error};
  }
}

Future<Map<String, dynamic>> searchCustomEmojis(String serverUrl, String term) async {
  try {
    final client = NetworkManager().getClient(serverUrl);
    final result = await DatabaseManager().getServerDatabaseAndOperator(serverUrl);
    final database = result['database'];
    final operator = result['operator'];

    final data = await client.searchCustomEmoji(term);
    if (data.isNotEmpty) {
      final names = data.map((c) => c.name).toList();
      final existingEmojis = await queryCustomEmojisByName(database, names).fetch();
      final existingNames = existingEmojis.map((e) => e.name).toSet();
      final emojis = data.where((d) => !existingNames.contains(d.name)).toList();
      await operator.handleCustomEmojis({
        'emojis': emojis,
        'prepareRecordsOnly': false,
      });
    }
    return {'data': data};
  } catch (error) {
    logDebug('error on searchCustomEmojis', getFullErrorMessage(error));
    forceLogoutIfNecessary(serverUrl, error);
    return {'error': error};
  }
}

final Set<String> names = Set<String>();
final debouncedFetchEmojiByNames = debounce((String serverUrl) async {
  try {
    final client = NetworkManager().getClient(serverUrl);
    final result = await DatabaseManager().getServerDatabaseAndOperator(serverUrl);
    final operator = result['operator'];

    final List<Future<CustomEmoji>> promises = [];
    for (final name in names) {
      promises.add(client.getCustomEmojiByName(name));
    }
    final emojisResult = await Future.wait(promises);
    final List<CustomEmoji> emojis = [];
    for (final result in emojisResult) {
      emojis.add(result);
    }
    if (emojis.isNotEmpty) {
      await operator.handleCustomEmojis({'emojis': emojis, 'prepareRecordsOnly': false});
    }
    return {};
  } catch (error) {
    logDebug('error on debouncedFetchEmojiByNames', getFullErrorMessage(error));
    return {'error': error};
  }
}, 200, false, () => names.clear());

Future<void> fetchCustomEmojiInBatch(String serverUrl, String emojiName) async {
  names.add(emojiName);
  await debouncedFetchEmojiByNames(serverUrl);
}
