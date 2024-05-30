// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:mattermost_flutter/types/constants.dart';

class Group {
  final String displayName;
  final String name;
  final String description;
  final String source;
  final String remoteId;
  final int createdAt;
  final int updatedAt;
  final int deletedAt;
  final int memberCount;

  Group({
    required this.displayName,
    required this.name,
    required this.description,
    required this.source,
    required this.remoteId,
    required this.createdAt,
    required this.updatedAt,
    required this.deletedAt,
    required this.memberCount,
  });

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      displayName: json['display_name'],
      name: json['name'],
      description: json['description'],
      source: json['source'],
      remoteId: json['remote_id'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      deletedAt: json['deleted_at'],
      memberCount: json['member_count'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'display_name': displayName,
      'name': name,
      'description': description,
      'source': source,
      'remote_id': remoteId,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'deleted_at': deletedAt,
      'member_count': memberCount,
    };
  }
}
