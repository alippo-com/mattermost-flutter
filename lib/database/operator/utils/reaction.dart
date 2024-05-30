// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:nozbe_watermelondb/watermelondb.dart';
import 'package:watermelondb/query.dart';

import 'package:mattermost_flutter/constants/database.dart';
import 'package:mattermost_flutter/models/servers/reaction.dart';

const REACTION = MM_TABLES.SERVER['REACTION'];

class SanitizeReactionsArgs {
  final Database database;
  final String postId;
  final List<RawReaction> rawReactions;
  final bool skipSync;

  SanitizeReactionsArgs({
    required this.database,
    required this.postId,
    required this.rawReactions,
    this.skipSync = false,
  });
}

Future<Map<String, List<dynamic>>> sanitizeReactions(SanitizeReactionsArgs args) async {
  final reactions = await args.database
      .get<ReactionModel>(REACTION)
      .query(Q.where('post_id', args.postId))
      .fetch();

  // similarObjects: Contains objects that are in both the RawReaction array and in the Reaction table
  final similarObjects = <ReactionModel>{};

  final createReactions = <Map<String, dynamic>>[];

  final reactionsMap = reactions.fold<Map<String, ReactionModel>>({}, (result, reaction) {
    result['${reaction.userId}-${reaction.emojiName}'] = reaction;
    return result;
  });

  for (final raw in args.rawReactions) {
    // If the reaction is not present let's add it to the db
    final exists = reactionsMap['${raw.userId}-${raw.emojiName}'];

    if (exists != null) {
      similarObjects.add(exists);
    } else {
      createReactions.add({'raw': raw});
    }
  }

  if (args.skipSync) {
    return {'createReactions': createReactions, 'deleteReactions': []};
  }

  // finding out elements to delete
  final deleteReactions = reactions.where((reaction) => !similarObjects.contains(reaction)).toList();

  return {'createReactions': createReactions, 'deleteReactions': deleteReactions};
}
