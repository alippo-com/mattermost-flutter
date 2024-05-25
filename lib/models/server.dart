import 'package:mattermost_flutter/types/MM_TABLES.dart';

class Server {
  String dbPath;
  String displayName;
  String url;
  int lastActiveAt;
  String identifier;

  Server({this.dbPath, this.displayName, this.url, this.lastActiveAt, this.identifier});

  factory Server.fromMap(Map<String, dynamic> json) => Server(
        dbPath: json['db_path'],
        displayName: json['display_name'],
        url: json['url'],
        lastActiveAt: json['last_active_at'],
        identifier: json['identifier'],
      );

  Map<String, dynamic> toMap() {
    return {
      'db_path': dbPath,
      'display_name': displayName,
      'url': url,
      'last_active_at': lastActiveAt,
      'identifier': identifier,
    };
  }
}
