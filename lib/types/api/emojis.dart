
// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

enum EmojiCategory {
  recent,
  smileys_emotion,
  people_body,
  animals_nature,
  food_drink,
  travel_places,
  activities,
  objects,
  symbols,
  flags,
  custom,
}

class CustomEmoji {
  final String id;
  final int create_at;
  final int update_at;
  final int delete_at;
  final String creator_id;
  final String name;

  CustomEmoji({required this.id, required this.create_at, required this.update_at, required this.delete_at, required this.creator_id, required this.name});
}

class SystemEmoji {
  final String filename;
  final List<String> aliases;
  final EmojiCategory category;
  final int batch;

  SystemEmoji({required this.filename, required this.aliases, required this.category, required this.batch});
}

class Emoji {
  final SystemEmoji? systemEmoji;
  final CustomEmoji? customEmoji;
  
  Emoji({this.systemEmoji, this.customEmoji});
}

class EmojisState {
  final Map<String, CustomEmoji> customEmoji;
  final Set<String> nonExistentEmoji;

  EmojisState({required this.customEmoji, required this.nonExistentEmoji});
}
