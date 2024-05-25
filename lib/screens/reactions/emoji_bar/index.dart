// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:mattermost_flutter/utils/device.dart'; // Custom hook to check if the device is a tablet
import 'package:mattermost_flutter/screens/reactions/emoji_bar/item.dart';
import 'package:mattermost_flutter/types/database/models/servers/reaction.dart'; // Import for ReactionModel

class EmojiBar extends StatefulWidget {
  final String emojiSelected;
  final Map<String, List<ReactionModel>> reactionsByName;
  final Function(int) setIndex;
  final List<String> sortedReactions;

  EmojiBar({
    required this.emojiSelected,
    required this.reactionsByName,
    required this.setIndex,
    required this.sortedReactions,
  });

  @override
  _EmojiBarState createState() => _EmojiBarState();
}

class _EmojiBarState extends State<EmojiBar> {
  final ScrollController _scrollController = ScrollController();
  late bool isTablet;

  @override
  void initState() {
    super.initState();
    isTablet = useIsTablet();
    WidgetsBinding.instance?.addPostFrameCallback((_) => scrollToItem(widget.emojiSelected));
  }

  void scrollToIndex(int index, {bool animated = false}) {
    _scrollController.animateTo(
      index.toDouble(),
      duration: Duration(milliseconds: animated ? 300 : 0),
      curve: Curves.easeInOut,
    );
  }

  void scrollToItem(String item) {
    int index = widget.sortedReactions.indexOf(item);
    if (index >= 0) {
      scrollToIndex(index);
    }
  }

  void onScrollToIndexFailed(int index, int highestMeasuredFrameIndex) {
    int targetIndex = index < highestMeasuredFrameIndex ? index : highestMeasuredFrameIndex;
    scrollToIndex(targetIndex);
  }

  void onPress(String emoji) {
    int index = widget.sortedReactions.indexOf(emoji);
    widget.setIndex(index);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: isTablet ? 12 : 0),
      constraints: BoxConstraints(maxHeight: 44),
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: widget.sortedReactions.length,
        itemBuilder: (context, index) {
          String item = widget.sortedReactions[index];
          return Item(
            count: widget.reactionsByName[item]?.length ?? 0,
            emojiName: item,
            highlight: item == widget.emojiSelected,
            onPress: () => onPress(item),
          );
        },
      ),
    );
  }
}
