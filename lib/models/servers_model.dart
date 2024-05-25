// Copyright (c) 2020-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:mattermost_flutter/types/model.dart';

/// The Server model will help us to identify the various servers a user will log in; in the context of
/// multi-server support system. The dbPath field will hold the App-Groups file-path
class ServersModel extends Model {
  /// Table (name) : servers
  static const String table = 'servers';

  /// dbPath : The file path where the database is stored
  String dbPath;

  /// displayName : The server display name
  String displayName;

  /// url : The online address for the Mattermost server
  String url;

  /// lastActiveAt: The last time this server was active
  int lastActiveAt;

  /// diagnosticId: Determines the installation identifier of a server
  String diagnosticId;

  ServersModel({
    this.dbPath,
    this.displayName,
    this.url,
    this.lastActiveAt,
    this.diagnosticId,
  });
}