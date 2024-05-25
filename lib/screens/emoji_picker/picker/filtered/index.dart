
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mattermost_flutter/constants/preferences.dart';
import 'package:mattermost_flutter/queries/servers/preference.dart';
import 'package:mattermost_flutter/types/database/database.dart';
import 'package:mattermost_flutter/screens/emoji_picker/picker/filtered.dart';

class EnhancedEmojiFiltered extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final database = Provider.of<Database>(context);
    final skinToneStream = queryEmojiPreferences(database, Preferences.EMOJI_SKINTONE)
        .observeWithColumns(['value'])
        .switchMap((prefs) => Stream.value(prefs?.isNotEmpty ?? false ? prefs.first.value : 'default'));

    return StreamProvider<String>(
      create: (_) => skinToneStream,
      initialData: 'default',
      child: EmojiFiltered(),
    );
  }
}
