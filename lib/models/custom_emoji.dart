// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:mattermost_flutter/types/model.dart';

/// The CustomEmoji model describes all the custom emojis used in the Mattermost app
class CustomEmoji extends Model {
  /// table (name) : CustomEmoji
  static const String table = 'CustomEmoji';

  /// name : The custom emoji's name
  final String name;

  CustomEmoji({required this.name});
}
