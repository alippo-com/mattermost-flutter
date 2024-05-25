
// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:watermelondb/watermelondb.dart';
import 'package:watermelondb/decorators.dart';

import 'package:mattermost_flutter/constants/database.dart';
import 'package:mattermost_flutter/utils/helpers.dart';

import 'package:mattermost_flutter/types/draft.dart';

class DraftModel extends Model with DraftModelInterface {
  static final table = MM_TABLES.SERVER.DRAFT;

  static final associations = {
    MM_TABLES.SERVER.CHANNEL: BelongsTo(key: 'channel_id'),
    MM_TABLES.SERVER.POST: BelongsTo(key: 'root_id'),
  };

  @Field('channel_id')
  late final String channelId;

  @Field('message')
  late final String message;

  @Field('root_id')
  late final String rootId;

  @Json('files', safeParseJSON)
  late final List<FileInfo> files;

  @Json('metadata', identity)
  final PostMetadata? metadata;
}
