// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:watermelondb/watermelondb.dart';
import 'package:rx_dart/rx_dart.dart';
import 'package:mattermost_flutter/constants/database.dart';
import 'package:mattermost_flutter/types/models/servers/draft.dart';

const DRAFT = MM_TABLES.SERVER.DRAFT;

Future<DraftModel?> getDraft(Database database, String channelId, [String rootId = '']) async {
  final record = await queryDraft(database, channelId, rootId).fetch();

  if (record.isNotEmpty) {
    return record[0];
  }
  return null;
}

Query<DraftModel> queryDraft(Database database, String channelId, [String rootId = '']) {
  return database.collections.get<DraftModel>(DRAFT).query(
    Q.where('channel_id', channelId),
    Q.where('root_id', rootId),
  );
}

Stream<DraftModel?> observeFirstDraft(List<DraftModel> drafts) {
  return drafts.isNotEmpty ? drafts[0].observe() : Stream.value(null);
}
