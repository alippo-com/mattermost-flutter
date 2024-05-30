
import 'package:flutter/material.dart';
import 'package:fast_image/fast_image.dart';
import 'package:provider/provider.dart';
import 'package:mattermost_flutter/types/emoji.dart';
import 'package:mattermost_flutter/types/database.dart';
import 'package:mattermost_flutter/context/server.dart';
import 'package:mattermost_flutter/utils/emoji.dart';
import 'package:mattermost_flutter/utils/emoji_helpers.dart';
import 'dart:io'; // Add this import

class Emoji extends StatelessWidget {
  final EmojiProps props;

  Emoji(this.props);

  @override
  Widget build(BuildContext context) {
    final serverUrl = Provider.of<ServerUrl>(context);
    final database = Provider.of<Database>(context);
    final emojiName = props.emojiName.trim();
    final name = props.emojiName.trim();
    String? assetImage;
    String? unicode;
    String? imageUrl;
    if (EmojiIndicesByAlias.containsKey(name)) {
      final emoji = Emojis[EmojiIndicesByAlias[name]!]!;
      if (emoji.category == 'custom') {
        assetImage = emoji.fileName;
      } else {
        unicode = emoji.image;
      }
    } else {
      final customEmoji = props.customEmojis.firstWhere((ce) => ce.name == name, orElse: () => null);
      try {
        final client = NetworkManager.getClient(serverUrl);
        imageUrl = client.getCustomEmojiImageUrl(customEmoji.id);
      } catch (_) {
        // do nothing
      }
        }

    double? size = props.size;
    double? fontSize = size;
    if (size == null && props.textStyle != null) {
      final textStyle = props.textStyle!;
      fontSize = textStyle.fontSize;
      size = fontSize;
    }

    if (props.displayTextOnly || (imageUrl == null && assetImage == null && unicode == null)) {
      return Text(
        props.literal,
        style: props.commonStyle?.merge(props.textStyle),
        key: Key(props.testID ?? ''),
      );
    }

    final width = size;
    final height = size;

    if (unicode != null && imageUrl == null) {
      final codeArray = unicode.split('-');
      final code = codeArray.fold<String>('', (acc, c) => acc + String.fromCharCode(int.parse(c, radix: 16)));
      return Text(
        code,
        style: props.commonStyle?.merge(props.textStyle).copyWith(fontSize: size, color: Colors.black),
        key: Key(props.testID ?? ''),
      );
    }

    if (assetImage != null) {
      final key = Platform.isAndroid ? '$assetImage-$height-$width' : null;
      final image = assetImages[assetImage];
      if (image == null) return Container();
      return Image(
        key: Key(key ?? ''),
        image: AssetImage(image),
        width: width,
        height: height,
        fit: BoxFit.contain,
      );
    }

    if (imageUrl == null) return Container();

    final key = Platform.isAndroid ? '$imageUrl-$height-$width' : null;

    return FastImage(
      key: Key(key ?? ''),
      url: imageUrl,
      width: width,
      height: height,
      fit: BoxFit.contain,
    );
  }
}

class EmojiProps {
  final List<CustomEmoji> customEmojis;
  final TextStyle? textStyle;
  final TextStyle? commonStyle;
  final bool displayTextOnly;
  final String emojiName;
  final double? size;
  final String literal;
  final String? testID;
  
  EmojiProps({
    required this.customEmojis,
    this.textStyle,
    this.commonStyle,
    required this.displayTextOnly,
    required this.emojiName,
    this.size,
    this.literal = '',
    this.testID,
  });
}

class CustomEmoji {
  final String name;
  final String id;

  CustomEmoji({
    required this.name,
    required this.id,
  });
}
