
// Dart code for `./mattermost_flutter/lib/components/autocomplete/emoji_suggestion/index.dart`

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mattermost_flutter/queries/servers/preference.dart';
import 'package:mattermost_flutter/components/autocomplete/emoji_suggestion/emoji_suggestion.dart';
import 'package:rx_dart/rx_dart.dart';

class EmojiSuggestionProvider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final database = Provider.of<Database>(context);

    final isCustomEmojisEnabled = observeConfigBooleanValue(database, 'EnableCustomEmoji');
    final customEmojis = isCustomEmojisEnabled.switchMap((enabled) {
      return enabled ? queryAllCustomEmojis(database).asObservable() : Observable.just([]);
    });

    final skinTone = queryEmojiPreferences(database, Preferences.EMOJI_SKINTONE)
        .observeWithColumns(['value'])
        .switchMap((prefs) => Observable.just(prefs.isNotEmpty ? prefs[0].value : 'default'));

    return EmojiSuggestion(
      customEmojis: customEmojis,
      skinTone: skinTone,
    );
  }
}
