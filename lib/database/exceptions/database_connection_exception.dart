// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

/// DatabaseConnectionException: This error can be thrown whenever an issue arises with the Database
class DatabaseConnectionException implements Exception {
  final String message;
  final String? tableName;
  DatabaseConnectionException(this.message, {this.tableName});
}
