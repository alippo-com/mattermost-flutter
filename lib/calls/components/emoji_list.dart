import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
// Assuming a corresponding file exists
import 'package:mattermost_flutter/calls/components/emoji_pill.dart';
import 'package:mattermost_flutter/calls/utils.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:flutter_linear_gradient/flutter_linear_gradient.dart';

class EmojiList extends HookWidget {
  final List<ReactionStreamEmoji> reactionStream;

  EmojiList({required this.reactionStream});

  @override
  Widget build(BuildContext context) {
    final theme = useTheme(context);
    final callsTheme = useMemo(() => makeCallsTheme(theme), [theme]);

    return Container(
      decoration: BoxDecoration(
        position: DecorationPosition.background,
      ),
      width: double.infinity,
      height: 48,
      child: Stack(
        children: [
          Row(
            children: reactionStream.map((e) => EmojiPill(
              key: ValueKey(e.latestTimestamp),
              name: e.name,
              literal: e.literal,
              count: e.count,
            )).toList(),
          ),
          Positioned.fill(
            child: LinearGradient(
              begin: Alignment(0.75, 0),
              end: Alignment(1, 0),
              colors: [
                changeOpacity(callsTheme.callsBg, 0),
                callsTheme.callsBg,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
