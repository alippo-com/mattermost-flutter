
// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

class EmojiAlias {
  final List<String> aliases;
  final String name;
  final String shortName;
  final String? category;

  EmojiAlias({required this.aliases, required this.name, required this.shortName, this.category});
}

class EmojiSection {
  final List<List<EmojiAlias>> data;
  final String? defaultMessage;
  final String icon;
  final String id;
  final String key;

  EmojiSection({required this.data, this.defaultMessage, required this.icon, required this.id, required this.key});
}

class CategoryTranslation {
  final String id;
  final String defaultMessage;
  final String icon;

  CategoryTranslation({required this.id, required this.defaultMessage, required this.icon});
}
