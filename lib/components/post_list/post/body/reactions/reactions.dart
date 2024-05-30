// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:mattermost_flutter/constants/emoji.dart';
import 'package:mattermost_flutter/utils/emoji/helpers.dart';
import 'package:mattermost_flutter/utils/tap.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/context/server.dart';
import 'package:mattermost_flutter/hooks/use_is_tablet.dart';
import 'package:mattermost_flutter/components/compass_icon.dart';
import 'package:mattermost_flutter/components/reaction.dart';
import 'package:mattermost_flutter/actions/remote/reactions.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'package:mattermost_flutter/types/theme.dart';
import 'package:mattermost_flutter/types/reaction_model.dart';

class Reactions extends HookWidget {
  final bool canAddReaction;
  final bool canRemoveReaction;
  final bool disabled;
  final String currentUserId;
  final String location;
  final String postId;
  final List<ReactionModel> reactions;
  final Theme theme;

  Reactions({
    required this.canAddReaction,
    required this.canRemoveReaction,
    required this.disabled,
    required this.currentUserId,
    required this.location,
    required this.postId,
    required this.reactions,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final intl = useIntl();
    final serverUrl = useServerUrl();
    final isTablet = useIsTablet();
    final pressed = useRef(false);
    final sortedReactions = useState<Set<String>>(reactions.map((r) => getEmojiFirstAlias(r.emojiName)).toSet());
    final styles = getStyleSheet(theme);

    useDidUpdate(() {
      final rs = reactions.map((r) => getEmojiFirstAlias(r.emojiName)).toList();
      final sorted = Set<String>.from(sortedReactions.value);
      final added = rs.where((r) => !sorted.contains(r)).toList();
      added.forEach(sorted.add);
      final removed = sorted.where((s) => !rs.contains(s)).toList();
      removed.forEach(sorted.remove);
      sortedReactions.value = sorted;
    }, [reactions]);

    final buildReactionsMap = useCallback(() {
      final highlightedReactions = <String>[];

      final reactionsByName = reactions.fold<Map<String, List<ReactionModel>>>({}, (acc, reaction) {
        if (reaction != null) {
          final emojiAlias = getEmojiFirstAlias(reaction.emojiName);
          if (acc.containsKey(emojiAlias)) {
            final rs = acc[emojiAlias]!;
            if (!rs.any((r) => r.userId == reaction.userId)) {
              rs.add(reaction);
            }
          } else {
            acc[emojiAlias] = [reaction];
          }

          if (reaction.userId == currentUserId) {
            highlightedReactions.add(emojiAlias);
          }
        }
        return acc;
      });

      return {'reactionsByName': reactionsByName, 'highlightedReactions': highlightedReactions};
    }, [sortedReactions.value, reactions]);

    final handleToggleReactionToPost = useCallback((emoji) {
      toggleReaction(serverUrl, postId, emoji);
    }, [serverUrl, postId]);

    final handleAddReaction = useCallback(preventDoubleTap(() {
      openAsBottomSheet(
        context,
        Screens.EMOJI_PICKER,
        {'onEmojiPress': handleToggleReactionToPost},
        modalOptions: bottomSheetModalOptions(theme, 'close-add-reaction'),
        title: intl.formatMessage(id: 'mobile.post_info.add_reaction', defaultMessage: 'Add Reaction'),
      );
    }), [intl, theme]);

    final handleReactionPress = useCallback((emoji, remove) async {
      pressed.value = true;
      if (remove && canRemoveReaction && !disabled) {
        await removeReaction(serverUrl, postId, emoji);
      } else if (!remove && canAddReaction && !disabled) {
        await addReaction(serverUrl, postId, emoji);
      }
      pressed.value = false;
    }, [canRemoveReaction, canAddReaction, disabled, serverUrl, postId]);

    final showReactionList = useCallback((initialEmoji) {
      Keyboard.dismiss();
      final title = isTablet ? intl.formatMessage(id: 'post.reactions.title', defaultMessage: 'Reactions') : '';

      if (!pressed.value) {
        if (isTablet) {
          showModal(
            context,
            Screens.REACTIONS,
            {'initialEmoji': initialEmoji, 'location': location, 'postId': postId},
            modalOptions: bottomSheetModalOptions(theme, 'close-post-reactions'),
            title: title,
          );
        } else {
          showModalOverCurrentContext(
            context,
            Screens.REACTIONS,
            {'initialEmoji': initialEmoji, 'location': location, 'postId': postId},
            modalOptions: bottomSheetModalOptions(theme),
          );
        }
      }
    }, [intl, isTablet, location, postId, theme]);

    final {reactionsByName, highlightedReactions} = buildReactionsMap();
    Widget addMoreReactions;
    if (!disabled && canAddReaction && reactionsByName.length < MAX_ALLOWED_REACTIONS) {
      addMoreReactions = GestureDetector(
        key: Key('addReaction'),
        onTap: handleAddReaction,
        child: Container(
          decoration: BoxDecoration(
            color: changeOpacity(theme.centerChannelColor, 0.08),
            borderRadius: BorderRadius.circular(4),
          ),
          padding: EdgeInsets.symmetric(vertical: 4, horizontal: 6),
          margin: EdgeInsets.only(right: 6, bottom: 12),
          height: 32,
          width: 36,
          child: Center(
            child: CompassIcon(
              name: 'emoticon-plus-outline',
              size: 24,
              color: changeOpacity(theme.centerChannelColor, 0.5),
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        ...sortedReactions.value.map((r) {
          final reaction = reactionsByName[r];
          return Reaction(
            key: Key(r),
            count: reaction?.length ?? 1,
            emojiName: r,
            highlight: highlightedReactions.contains(r),
            onPress: handleReactionPress,
            onLongPress: showReactionList,
            theme: theme,
          );
        }).toList(),
        addMoreReactions,
      ],
    );
  }

  Map<String, dynamic> getStyleSheet(Theme theme) {
    return {
      'addReaction': {
        'color': changeOpacity(theme.centerChannelColor, 0.5),
      },
      'reaction': {
        'alignItems': 'center',
        'justifyContent': 'center',
        'borderRadius': 4,
        'backgroundColor': changeOpacity(theme.centerChannelColor, 0.08),
        'flexDirection': 'row',
        'height': 32,
        'marginBottom': 12,
        'marginRight': 6,
        'paddingVertical': 4,
        'paddingHorizontal': 6,
        'width': 36,
      },
    };
  }
}
