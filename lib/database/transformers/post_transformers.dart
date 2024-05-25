// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:mattermost_flutter/constants/database.dart';
import 'package:mattermost_flutter/database/transformers/index.dart';
import 'package:mattermost_flutter/types/transformer_args.dart';
import 'package:mattermost_flutter/types/draft_model.dart';
import 'package:mattermost_flutter/types/file_model.dart';
import 'package:mattermost_flutter/types/post_model.dart';
import 'package:mattermost_flutter/types/posts_in_channel_model.dart';
import 'package:mattermost_flutter/types/posts_in_thread_model.dart';

class PostTransformers {
  static Future<PostModel> transformPostRecord(TransformerArgs args) async {
    final raw = args.value.raw as Post;
    final record = args.value.record as PostModel;
    final isCreateAction = args.action == OperationType.CREATE;

    void fieldsMapper(PostModel post) {
      post.raw.id = isCreateAction ? (raw?.id ?? post.id) : record.id;
      post.channelId = raw.channelId;
      post.createAt = raw.createAt;
      post.deleteAt = raw.deleteAt ?? 0;
      post.editAt = raw.editAt;
      post.updateAt = raw.updateAt;
      post.isPinned = raw.isPinned;
      post.message = raw.message;
      post.messageSource = raw.messageSource ?? '';

      final metadata = raw.metadata ?? post.metadata;
      post.metadata = metadata != null && metadata.keys.isNotEmpty ? metadata : null;

      post.userId = raw.userId;
      post.originalId = raw.originalId;
      post.pendingPostId = raw.pendingPostId;
      post.previousPostId = raw.previousPostId ?? '';
      post.rootId = raw.rootId;
      post.type = raw.type ?? '';
      post.props = raw.props ?? {};
    }

    return prepareBaseRecord(
      action: args.action,
      database: args.database,
      tableName: MM_TABLES.SERVER.POST,
      value: args.value,
      fieldsMapper: fieldsMapper,
    ) as Future<PostModel>;
  }

  static Future<PostsInThreadModel> transformPostInThreadRecord(TransformerArgs args) async {
    final raw = args.value.raw as PostsInThread;
    final record = args.value.record as PostsInThreadModel;
    final isCreateAction = args.action == OperationType.CREATE;

    void fieldsMapper(PostsInThreadModel postsInThread) {
      postsInThread.raw.id = isCreateAction ? (raw.id ?? postsInThread.id) : record.id;
      postsInThread.rootId = raw.rootId;
      postsInThread.earliest = raw.earliest;
      postsInThread.latest = raw.latest;
    }

    return prepareBaseRecord(
      action: args.action,
      database: args.database,
      tableName: MM_TABLES.SERVER.POSTS_IN_THREAD,
      value: args.value,
      fieldsMapper: fieldsMapper,
    ) as Future<PostsInThreadModel>;
  }

  static Future<FileModel> transformFileRecord(TransformerArgs args) async {
    final raw = args.value.raw as FileInfo;
    final record = args.value.record as FileModel;
    final isCreateAction = args.action == OperationType.CREATE;

    void fieldsMapper(FileModel file) {
      file.raw.id = isCreateAction ? (raw.id ?? file.id) : record.id;
      file.postId = raw.postId;
      file.name = raw.name;
      file.extension = raw.extension;
      file.size = raw.size;
      file.mimeType = raw.mimeType ?? '';
      file.width = raw.width ?? record.width ?? 0;
      file.height = raw.height ?? record.height ?? 0;
      file.imageThumbnail = raw.imageThumbnail ?? record.imageThumbnail ?? '';
      file.localPath = raw.localPath ?? record.localPath;
    }

    return prepareBaseRecord(
      action: args.action,
      database: args.database,
      tableName: MM_TABLES.SERVER.FILE,
      value: args.value,
      fieldsMapper: fieldsMapper,
    ) as Future<FileModel>;
  }

  static Future<DraftModel> transformDraftRecord(TransformerArgs args) async {
    final emptyFileInfo = <FileInfo>[];
    final emptyPostMetadata = <String, dynamic>{};
    final raw = args.value.raw as Draft;

    void fieldsMapper(DraftModel draft) {
      draft.raw.id = draft.id;
      draft.rootId = raw.rootId ?? '';
      draft.message = raw.message ?? '';
      draft.channelId = raw.channelId ?? '';
      draft.files = raw.files ?? emptyFileInfo;
      draft.metadata = raw.metadata ?? emptyPostMetadata;
    }

    return prepareBaseRecord(
      action: args.action,
      database: args.database,
      tableName: MM_TABLES.SERVER.DRAFT,
      value: args.value,
      fieldsMapper: fieldsMapper,
    ) as Future<DraftModel>;
  }

  static Future<PostsInChannelModel> transformPostsInChannelRecord(TransformerArgs args) async {
    final raw = args.value.raw as PostsInChannel;
    final record = args.value.record as PostsInChannelModel;
    final isCreateAction = args.action == OperationType.CREATE;

    void fieldsMapper(PostsInChannelModel postsInChannel) {
      postsInChannel.raw.id = isCreateAction ? (raw.id ?? postsInChannel.id) : record.id;
      postsInChannel.channelId = raw.channelId;
      postsInChannel.earliest = raw.earliest;
      postsInChannel.latest = raw.latest;
    }

    return prepareBaseRecord(
      action: args.action,
      database: args.database,
      tableName: MM_TABLES.SERVER.POSTS_IN_CHANNEL,
      value: args.value,
      fieldsMapper: fieldsMapper,
    ) as Future<PostsInChannelModel>;
  }
}
