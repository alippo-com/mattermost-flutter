// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

class Bot {
  String user_id;
  String username;
  String display_name;
  String description;
  String owner_id;
  int create_at;
  int update_at;
  int delete_at;

  Bot(
      {required this.user_id,
      required this.username,
      required this.display_name,
      required this.description,
      required this.owner_id,
      required this.create_at,
      required this.update_at,
      required this.delete_at});
}

// BotPatch is a description of what fields to update on an existing bot.
class BotPatch {
  String username;
  String display_name;
  String description;

  BotPatch(
      {required this.username,
      required this.display_name,
      required this.description});
}
