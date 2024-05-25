// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:mattermost_flutter/types/watermelondb/model.dart';

/// The CustomEmoji model describes all the custom emojis used in the Mattermost app
class CustomEmojiModel extends Model {
  /// table (name) : CustomEmoji
  static final String table = 'CustomEmoji';

  /// name :  The custom emoji's name
  String name;

  CustomEmojiModel({required this.name});
}
