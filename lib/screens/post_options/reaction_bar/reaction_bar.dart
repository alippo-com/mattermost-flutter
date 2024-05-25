
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';
import 'package:mattermost_flutter/constants/general.dart';
import 'package:mattermost_flutter/constants/reaction_picker.dart';
import 'package:mattermost_flutter/screens/navigation.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/hooks/device.dart';
import 'package:mattermost_flutter/actions/remote/reactions.dart';
import 'package:mattermost_flutter/context/server.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'pick_reaction.dart';
import 'reaction.dart';
import 'package:mattermost_flutter/types/screens/navigation.dart';

class QuickReactionProps {
  final AvailableScreens bottomSheetId;
  final List<String> recentEmojis;
  final String postId;

  QuickReactionProps({
    required this.bottomSheetId,
    required this.recentEmojis,
    required this.postId,
  });
}

class ReactionBar extends HookWidget {
  final QuickReactionProps props;

  ReactionBar({required this.props});

  @override
  Widget build(BuildContext context) {
    final theme = useTheme(context);
    final intl = useIntl(context);
    final width = MediaQuery.of(context).size.width;
    final serverUrl = useServerUrl(context);
    final isSmallDevice = width < SMALL_ICON_BREAKPOINT;
    final styles = getStyleSheet(theme);
    final isTablet = useIsTablet(context);

    final handleEmojiPress = useCallback((emoji) async {
      await dismissBottomSheet(props.bottomSheetId);
      toggleReaction(serverUrl, props.postId, emoji);
    }, [props.bottomSheetId, props.postId, serverUrl]);

    final openEmojiPicker = useCallback(() async {
      await dismissBottomSheet(props.bottomSheetId);
      openAsBottomSheet(
        closeButtonId: 'close-add-reaction',
        screen: Screens.EMOJI_PICKER,
        theme: theme,
        title: intl.formatMessage('mobile.post_info.add_reaction', 'Add Reaction'),
        props: {'onEmojiPress': handleEmojiPress},
      );
    }, [handleEmojiPress, intl, theme]);

    var containerSize = LARGE_CONTAINER_SIZE;
    var iconSize = LARGE_ICON_SIZE;

    if (isSmallDevice) {
      containerSize = SMALL_CONTAINER_SIZE;
      iconSize = SMALL_ICON_SIZE;
    }

    return Container(
      margin: EdgeInsets.only(top: isTablet ? 12 : 0),
      color: theme.centerChannelBg,
      height: REACTION_PICKER_HEIGHT,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          ...props.recentEmojis.map((emoji) {
            return Reaction(
              key: Key(emoji),
              onPressReaction: handleEmojiPress,
              emoji: emoji,
              iconSize: iconSize,
              containerSize: containerSize,
              testID: 'post_options.reaction_bar.reaction',
            );
          }).toList(),
          PickReaction(
            openEmojiPicker: openEmojiPicker,
            width: containerSize,
            height: containerSize,
          ),
        ],
      ),
    );
  }
}

getStyleSheet(ThemeData theme) {
  return {
    'container': BoxDecoration(
      color: theme.centerChannelBg,
      borderRadius: BorderRadius.circular(8),
    )
  };
}
