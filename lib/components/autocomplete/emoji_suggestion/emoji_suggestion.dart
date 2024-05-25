import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:debounce_throttle/debounce_throttle.dart'; // For debounce functionality
import 'package:mattermost_flutter/hooks/safe_area.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/helpers.dart';
import 'package:mattermost_flutter/components/emoji.dart';
import 'package:mattermost_flutter/components/touchable_with_feedback.dart';

class EmojiSuggestion extends HookWidget {
  final int cursorPosition;
  final List<String> customEmojis;
  final Function(String) updateValue;
  final Function(bool) onShowingChange;
  final String? rootId;
  final String value;
  final bool nestedScrollEnabled;
  final String skinTone;
  final bool hasFilesAttached;
  final bool inPost;
  final TextStyle listStyle;

  EmojiSuggestion({
    required this.cursorPosition,
    required this.customEmojis,
    required this.updateValue,
    required this.onShowingChange,
    this.rootId,
    required this.value,
    required this.nestedScrollEnabled,
    required this.skinTone,
    this.hasFilesAttached = false,
    required this.inPost,
    required this.listStyle,
  });

  @override
  Widget build(BuildContext context) {
    final insets = useSafeAreaInsets();
    final theme = useTheme();
    final style = getStyleFromTheme(theme);
    
    final containerStyle = useMemo(() => EdgeInsets.only(bottom: insets.bottom + 12), [insets.bottom]);
    final emojis = useMemo(() => getEmojis(skinTone, customEmojis), [skinTone, customEmojis]);
    
    final searchTerm = useMemo(() {
      final match = RegExp(r'(^|\s|^\+|^-)(:([^:\s]*))$', caseSensitive: false).firstMatch(value.substring(0, cursorPosition));
      return match?.group(3) ?? '';
    }, [value, cursorPosition]);
    
    final fuse = useMemo(() => Fuse(emojis, options: FUSE_OPTIONS), [emojis]);
    
    final data = useMemo(() {
      if (searchTerm.length < MIN_SEARCH_LENGTH) {
        return [];
      }
      return searchEmojis(fuse, searchTerm);
    }, [fuse, searchTerm]);
    
    final showingElements = data.isNotEmpty;

    void completeSuggestion(String emoji) {
      // Add the logic for completing the suggestion
    }
    
    Widget renderItem(String item) {
      return TouchableWithFeedback(
        onPress: () => completeSuggestion(item),
        child: Container(
          height: 40,
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Container(
                margin: EdgeInsets.only(right: 5),
                child: Emoji(
                  emojiName: item,
                  textStyle: style.emojiText,
                  size: EMOJI_SIZE,
                ),
              ),
              Text(
                ':$item:',
                style: style.emojiName,
              ),
            ],
          ),
        ),
      );
    }

    useEffect(() {
      onShowingChange(showingElements);
    }, [showingElements]);

    useEffect(() {
      final debounce = Debouncer<String>(Duration(milliseconds: SEARCH_DELAY));
      debounce.value = searchTerm;
      debounce.values.listen((value) {
        if (value.length >= MIN_SEARCH_LENGTH) {
          searchCustomEmojis(serverUrl, value);
        }
      });
      return () => debounce.dispose();
    }, [searchTerm]);

    if (data.isEmpty) {
      return Container();
    }

    return ListView.builder(
      padding: containerStyle,
      itemCount: data.length,
      itemBuilder: (context, index) {
        return renderItem(data[index]);
      },
    );
  }

  Map<String, dynamic> getStyleFromTheme(ThemeData theme) {
    return {
      'emoji': {
        'marginRight': 5.0,
      },
      'emojiName': {
        'fontSize': 15.0,
        'color': theme.centerChannelColor,
      },
      'emojiText': {
        'color': Colors.black,
        'fontWeight': FontWeight.bold,
      },
      'listView': {
        'paddingTop': 16.0,
      },
      'row': {
        'flexDirection': 'row',
        'alignItems': 'center',
        'overflow': 'hidden',
        'paddingBottom': 8.0,
        'height': 40.0,
      },
    };
  }
}
