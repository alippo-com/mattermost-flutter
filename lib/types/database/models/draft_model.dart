// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:watermelondb/watermelondb.dart';
import 'package:watermelondb/associations.dart';
import 'package:mattermost_flutter/types/file_info.dart';
import 'package:mattermost_flutter/types/post_metadata.dart';

/**
 * The Draft model represents the draft state of messages in Direct/Group messages and in channels
 */
class DraftModel extends Model {
  /** table (name) : Draft */
  static const String tableName = 'Draft';

  /** associations : Describes every relationship to this table. */
  static final Associations associations = {
    // Define associations here
  };

  /** channel_id : The foreign key pointing to the channel in which the draft was made */
  String channelId;

  /** message : The draft message */
  String message;

  /** root_id : The root_id will be empty most of the time unless the draft relates to a draft reply of a thread */
  String rootId;

  /** files : The files field will hold an array of files object that have not yet been uploaded and persisted within the FILE table */
  List<FileInfo> files;

  PostMetadata? metadata;

  DraftModel({
    required this.channelId,
    required this.message,
    required this.rootId,
    required this.files,
    this.metadata,
  });
}
