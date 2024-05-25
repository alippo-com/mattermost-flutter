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

class Session {
  final String id;
  final int createAt;
  final String? deviceId;
  final int expiresAt;
  final String userId;
  final Map<String, String>? props;

  Session({
    required this.id,
    required this.createAt,
    this.deviceId,
    required this.expiresAt,
    required this.userId,
    this.props,
  });
}

class LoginActionResponse {
  final dynamic error;
  final bool failed;

  LoginActionResponse({
    this.error,
    required this.failed,
  });
}
