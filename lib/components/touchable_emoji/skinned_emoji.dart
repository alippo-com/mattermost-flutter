import 'package:flutter/material.dart';
import 'package:mattermost_flutter/components/emoji.dart';
import 'package:mattermost_flutter/utils/emoji.dart';
import 'package:mattermost_flutter/utils/tap.dart';

class SkinnedEmoji extends StatelessWidget {
  final String name;
  final Function(String emoji) onEmojiPress;
  final double size;
  final TextStyle? style;

  SkinnedEmoji({
    required this.name,
    required this.onEmojiPress,
    this.size = 30.0,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final skinTone = useEmojiSkinTone();
    final emojiName = useMemo(() {
      final skinnedEmoji = '${name}_${skinCodes[skinTone]}';
      if (skinTone == 'default' || !isValidNamedEmoji(skinnedEmoji, [])) {
        return name;
      }
      return skinnedEmoji;
    }, [name, skinTone]);

    final onPress = useCallback(preventDoubleTap(() {
      onEmojiPress(emojiName);
    }), [emojiName]);

    return Container(
      child: GestureDetector(
        onTap: onPress,
        child: Emoji(
          emojiName: emojiName,
          size: size,
        ),
      ),
    );
  }
}
