
// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

/// Flutter representation of the ApiError type from Mattermost.
class ApiError {
  final String? serverErrorId;
  final String? stack;
  final String message;
  final int? statusCode;

  ApiError({
    this.serverErrorId,
    this.stack,
    required this.message,
    this.statusCode,
  });
}
