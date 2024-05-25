// Dart Code: ./mattermost_flutter/lib/queries/servers/custom_emoji.dart

import 'package:nozbe_watermelondb/database.dart';
import 'package:nozbe_watermelondb/queries/where.dart';

import 'package:mattermost_flutter/constants/database.dart';
import 'package:mattermost_flutter/types/database/models/servers/custom_emoji.dart';

class CustomEmojiQueries {
  static const String CUSTOM_EMOJI = MM_TABLES['SERVER']['CUSTOM_EMOJI'];

  static Query<CustomEmojiModel> queryAllCustomEmojis(Database database) {
    return database.get<CustomEmojiModel>(CUSTOM_EMOJI).query();
  }

  static Query<CustomEmojiModel> queryCustomEmojisByName(Database database, List<String> names) {
    return database.get<CustomEmojiModel>(CUSTOM_EMOJI).query(
      Where('name', names),
    );
  }
}
