
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

import 'package:mattermost_flutter/screens/post_options/reaction_bar/reaction_bar.dart';

const List<String> DEFAULT_EMOJIS = [
  '+1',
  'smiley',
  'white_check_mark',
  'heart',
  'eyes',
  'raised_hands',
];

List<String> mergeRecentWithDefault(List<String> recentEmojis) {
  final List<String> emojiAliases = recentEmojis.take(6).map((emoji) => getEmojiFirstAlias(emoji)).toList();
  final Set<String> emojisSet = Set.from(emojiAliases);
  final List<String> filterUsed = DEFAULT_EMOJIS.where((e) => !emojisSet.contains(e)).toList();
  return emojiAliases..addAll(filterUsed.take(6 - emojiAliases.length));
}

class ReactionBarWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final database = Provider.of<Database>(context);

    return StreamBuilder<List<String>>(
      stream: observeRecentReactions(database).switchMap((recent) => Stream.value(mergeRecentWithDefault(recent))),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }
        return ReactionBar(recentEmojis: snapshot.data!);
      },
    );
  }
}

Stream<List<String>> observeRecentReactions(Database database) {
  // Implementation for observing recent reactions
  // This function needs to be implemented based on the actual database and query logic
  // Here, it's just a placeholder.
  return Stream.empty();
}

String getEmojiFirstAlias(String emoji) {
  // Implementation for getting the first alias of an emoji
  // This function needs to be implemented based on the actual emoji helper logic.
  // Here, it's just a placeholder.
  return emoji;
}
