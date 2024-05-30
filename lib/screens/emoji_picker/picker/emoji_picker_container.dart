// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:mattermost_flutter/database/database.dart';
import 'package:mattermost_flutter/screens/emoji_picker/picker/picker.dart';

class EmojiPickerContainer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final database = DatabaseProvider.of(context);

    return StreamBuilder(
      stream: Rx.combineLatest3(
        observeConfigBooleanValue(database, 'EnableCustomEmoji'),
        queryAllCustomEmojis(database).observe(),
        observeRecentReactions(database),
        (customEmojisEnabled, customEmojis, recentEmojis) {
          return {
            'customEmojisEnabled': customEmojisEnabled,
            'customEmojis': customEmojis,
            'recentEmojis': recentEmojis,
          };
        },
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }

        final data = snapshot.data as Map<String, dynamic>;
        return Picker(
          customEmojisEnabled: data['customEmojisEnabled'],
          customEmojis: data['customEmojis'],
          recentEmojis: data['recentEmojis'],
        );
      },
    );
  }
}
