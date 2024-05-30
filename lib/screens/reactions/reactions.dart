
// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:mattermost_flutter/constants.dart';
import 'package:mattermost_flutter/screens/bottom_sheet.dart';
import 'package:mattermost_flutter/utils/emoji/helpers.dart';
import 'package:mattermost_flutter/screens/reactions/emoji_aliases.dart';
import 'package:mattermost_flutter/screens/reactions/emoji_bar.dart';
import 'package:mattermost_flutter/screens/reactions/reactors_list.dart';
import 'package:mattermost_flutter/types/reaction_model.dart';

class Reactions extends StatefulWidget {
  final String initialEmoji;
  final String location;
  final List<ReactionModel>? reactions;

  const Reactions({
    Key? key,
    required this.initialEmoji,
    required this.location,
    this.reactions,
  }) : super(key: key);

  @override
  _ReactionsState createState() => _ReactionsState();
}

class _ReactionsState extends State<Reactions> {
  late List<String> sortedReactions;
  late int index;
  late Map<String, List<ReactionModel>> reactionsByName;

  @override
  void initState() {
    super.initState();
    sortedReactions = widget.reactions != null
        ? widget.reactions!
            .map((reaction) => getEmojiFirstAlias(reaction.emojiName))
            .toSet()
            .toList()
        : [];
    index = sortedReactions.indexOf(widget.initialEmoji);

    reactionsByName = widget.reactions != null
        ? widget.reactions!.fold<Map<String, List<ReactionModel>>>(
            {},
            (acc, reaction) {
              final emojiAlias = getEmojiFirstAlias(reaction.emojiName);
              if (acc.containsKey(emojiAlias)) {
                final rs = acc[emojiAlias]!;
                if (!rs.any((r) => r.userId == reaction.userId)) {
                  rs.add(reaction);
                }
              } else {
                acc[emojiAlias] = [reaction];
              }
              return acc;
            },
          )
        : {};
  }

  @override
  void didUpdateWidget(covariant Reactions oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.reactions != oldWidget.reactions) {
      final rs = widget.reactions
          ?.map((reaction) => getEmojiFirstAlias(reaction.emojiName))
          .toList();
      final sorted = sortedReactions.toSet();
      final added = rs?.where((r) => !sorted.contains(r)).toList();
      added?.forEach(sorted.add);
      final removed = sorted.where((s) => rs?.contains(s) == false).toList();
      removed.forEach(sorted.remove);
      setState(() {
        sortedReactions = sorted.toList();
      });
    }
  }

  Widget renderContent() {
    final emojiAlias = sortedReactions[index];
    if (reactionsByName.isEmpty) {
      return Container();
    }

    return Column(
      children: [
        EmojiBar(
          emojiSelected: emojiAlias,
          reactionsByName: reactionsByName,
          setIndex: (newIndex) => setState(() {
            index = newIndex;
          }),
          sortedReactions: sortedReactions,
        ),
        EmojiAliases(emoji: emojiAlias),
        ReactorsList(
          key: ValueKey(emojiAlias),
          location: widget.location,
          reactions: reactionsByName[emojiAlias]!,
          type: useIsTablet() ? 'FlatList' : 'BottomSheetFlatList',
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomSheet(
      renderContent: renderContent,
      closeButtonId: 'close-post-reactions',
      componentId: Screens.REACTIONS,
      initialSnapIndex: 1,
      snapPoints: [1, '50%', '80%'],
      testID: 'reactions',
    );
  }
}
