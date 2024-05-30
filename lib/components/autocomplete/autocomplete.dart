import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_reaction/flutter_reaction.dart'; // Hypothetical for animations

import 'package:mattermost_flutter/constants/autocomplete.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/components/autocomplete/at_mention.dart';
import 'package:mattermost_flutter/components/autocomplete/channel_mention.dart';
import 'package:mattermost_flutter/components/autocomplete/emoji_suggestion.dart';
import 'package:mattermost_flutter/components/autocomplete/slash_suggestion.dart';
import 'package:mattermost_flutter/components/autocomplete/app_slash_suggestion.dart';

class Autocomplete extends HookWidget {
  final int cursorPosition;
  final ValueNotifier<double> position;
  final String? rootId;
  final String? channelId;
  final bool isSearch;
  final String value;
  final ValueNotifier<double> availableSpace;
  final bool isAppsEnabled;
  final bool nestedScrollEnabled;
  final void Function(String) updateValue;
  final bool? hasFilesAttached;
  final bool inPost;
  final bool growDown;
  final String? teamId;
  final BoxDecoration? containerStyle;

  Autocomplete({
    required this.cursorPosition,
    required this.position,
    this.rootId,
    this.channelId,
    this.isSearch = false,
    required this.value,
    required this.availableSpace,
    required this.isAppsEnabled,
    this.nestedScrollEnabled = false,
    required this.updateValue,
    this.hasFilesAttached,
    this.inPost = false,
    this.growDown = false,
    this.teamId,
    this.containerStyle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = useTheme(context);
    final isTablet = useIsTablet(context);
    final dimensions = MediaQuery.of(context).size;

    final showingAtMention = useState(false);
    final showingChannelMention = useState(false);
    final showingEmoji = useState(false);
    final showingCommand = useState(false);
    final showingAppCommand = useState(false);

    final hasElements = showingChannelMention.value ||
        showingEmoji.value ||
        showingAtMention.value ||
        showingCommand.value ||
        showingAppCommand.value;
    final appsTakeOver = showingAppCommand.value;
    final showCommands = !(showingChannelMention.value || showingEmoji.value || showingAtMention.value);

    final isLandscape = dimensions.width > dimensions.height;
    final maxHeightAdjust = (isTablet && isLandscape) ? MAX_LIST_TABLET_DIFF : 0;
    final defaultMaxHeight = MAX_LIST_HEIGHT - maxHeightAdjust;
    final maxHeight = useMemoized(() => min(availableSpace.value, defaultMaxHeight), [defaultMaxHeight]);

    final containerAnimatedStyle = useAnimatedStyle(() {
      return growDown
          ? {'top': position.value, 'bottom': Platform.isIOS ? 'auto' : null, 'maxHeight': maxHeight.value}
          : {'top': Platform.isIOS ? 'auto' : null, 'bottom': position.value, 'maxHeight': maxHeight.value};
    }, [growDown, position]);

    final containerStyles = useMemoized(() {
      final s = [getStyleFromTheme(theme).base, containerAnimatedStyle];
      if (hasElements) {
        s.add(getStyleFromTheme(theme).borders);
      }
      if (Platform.isIOS) {
        s.add(getStyleFromTheme(theme).shadow);
      }
      if (containerStyle != null) {
        s.add(containerStyle);
      }
      return s;
    }, [hasElements, getStyleFromTheme(theme), containerStyle, containerAnimatedStyle]);

    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      child: Column(
        children: [
          if (isAppsEnabled && channelId != null)
            AppSlashSuggestion(
              listStyle: getStyleFromTheme(theme).listStyle,
              updateValue: updateValue,
              onShowingChange: (showing) => showingAppCommand.value = showing,
              value: value,
              nestedScrollEnabled: nestedScrollEnabled,
              channelId: channelId!,
              rootId: rootId,
            ),
          if (!(appsTakeOver && isAppsEnabled)) ...[
            AtMention(
              cursorPosition: cursorPosition,
              listStyle: getStyleFromTheme(theme).listStyle,
              updateValue: updateValue,
              onShowingChange: (showing) => showingAtMention.value = showing,
              value: value,
              nestedScrollEnabled: nestedScrollEnabled,
              isSearch: isSearch,
              channelId: channelId,
              teamId: teamId,
            ),
            ChannelMention(
              cursorPosition: cursorPosition,
              listStyle: getStyleFromTheme(theme).listStyle,
              updateValue: updateValue,
              onShowingChange: (showing) => showingChannelMention.value = showing,
              value: value,
              nestedScrollEnabled: nestedScrollEnabled,
              isSearch: isSearch,
              channelId: channelId,
              teamId: teamId,
            ),
            if (!isSearch)
              EmojiSuggestion(
                cursorPosition: cursorPosition,
                listStyle: getStyleFromTheme(theme).listStyle,
                updateValue: updateValue,
                onShowingChange: (showing) => showingEmoji.value = showing,
                value: value,
                nestedScrollEnabled: nestedScrollEnabled,
                rootId: rootId,
                hasFilesAttached: hasFilesAttached,
                inPost: inPost,
              ),
            if (showCommands && channelId != null)
              SlashSuggestion(
                listStyle: getStyleFromTheme(theme).listStyle,
                updateValue: updateValue,
                onShowingChange: (showing) => showingCommand.value = showing,
                value: value,
                nestedScrollEnabled: nestedScrollEnabled,
                channelId: channelId!,
                rootId: rootId,
                isAppsEnabled: isAppsEnabled,
              ),
          ],
        ],
      ),
    );
  }
}

class AutoCompleteStyles {
  static BoxDecoration base(BuildContext context) {
    final theme = useTheme(context);
    return BoxDecoration(
      color: Colors.transparent,
      boxShadow: [
        BoxShadow(
          color: changeOpacity(theme.centerChannelColor, 0.2),
          blurRadius: 6,
          offset: Offset(0, 6),
        ),
      ],
    );
  }

  static BoxDecoration borders(BuildContext context) {
    final theme = useTheme(context);
    return BoxDecoration(
      border: Border.all(color: changeOpacity(theme.centerChannelColor, 0.2), width: 1),
      borderRadius: BorderRadius.circular(8),
      color: theme.centerChannelBg,
    );
  }

  static BoxDecoration shadow(BuildContext context) {
    return BoxDecoration(
      color: Colors.transparent,
      boxShadow: [
        BoxShadow(
          color: Colors.black,
          blurRadius: 6,
          offset: Offset(0, 6),
        ),
      ],
    );
  }

  static BoxDecoration listStyle(BuildContext context) {
    final theme = useTheme(context);
    return BoxDecoration(
      color: theme.centerChannelBg,
      borderRadius: BorderRadius.circular(4),
      padding: EdgeInsets.symmetric(horizontal: 16),
    );
  }
}
