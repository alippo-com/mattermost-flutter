// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

class SlashCommand {
  String id;
  bool auto_complete;
  String auto_complete_desc;
  String auto_complete_hint;
  int create_at;
  String creator_id;
  int delete_at;
  String description;
  String display_name;
  String icon_url;
  String method;
  String team_id;
  String token;
  String trigger;
  int update_at;
  String url;
  String username;

  SlashCommand({
    required this.id,
    required this.auto_complete,
    required this.auto_complete_desc,
    required this.auto_complete_hint,
    required this.create_at,
    required this.creator_id,
    required this.delete_at,
    required this.description,
    required this.display_name,
    required this.icon_url,
    required this.method,
    required this.team_id,
    required this.token,
    required this.trigger,
    required this.update_at,
    required this.url,
    required this.username,
  });
}
