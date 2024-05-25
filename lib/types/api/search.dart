
// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

/// Flutter representation of the FileSearchRequest from Mattermost.
class FileSearchRequest {
  final dynamic error;
  final Map<String, dynamic>? fileInfos;
  final String? nextFileInfoId;
  final List<String>? order;
  final String? prevFileInfoId;

  FileSearchRequest({
    this.error,
    this.fileInfos,
    this.nextFileInfoId,
    this.order,
    this.prevFileInfoId,
  });
}

/// Flutter representation of the PostSearchRequest from Mattermost.
class PostSearchRequest {
  final dynamic error;
  final List<String>? order;
  final List<dynamic>? posts;
  final dynamic matches;

  PostSearchRequest({
    this.error,
    this.order,
    this.posts,
    this.matches,
  });
}
