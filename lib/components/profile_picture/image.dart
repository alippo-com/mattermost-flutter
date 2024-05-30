import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_reaction/flutter_reaction.dart'; // Hypothetical for animations

import 'package:mattermost_flutter/components/compass_icon.dart';
import 'package:mattermost_flutter/constants/profile.dart';
import 'package:mattermost_flutter/context/server.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/utils/theme.dart';

class Image extends HookWidget {
  final UserModel? author;
  final GlobalKey? forwardRef;
  final double? iconSize;
  final double size;
  final dynamic source;
  final String? url;

  Image({
    this.author,
    this.forwardRef,
    this.iconSize,
    required this.size,
    this.source,
    this.url,
  });

  @override
  Widget build(BuildContext context) {
    final theme = useTheme(context);
    var serverUrl = useServerUrl(context);
    serverUrl = url ?? serverUrl;

    final style = getStyleSheet(theme);
    final fIStyle = useMemoize(() => BoxDecoration(
      borderRadius: BorderRadius.circular(size / 2),
      color: theme.centerChannelBg,
    ), [size]);

    if (source is String) {
      return CompassIcon(
        name: source,
        size: iconSize ?? size,
        style: TextStyle(color: changeOpacity(theme.centerChannelColor, 0.48)),
      );
    }

    Client? client;
    try {
      client = NetworkManager.getClient(serverUrl);
    } catch {
      // handle below that the client is not set
    }

    if (author != null && client != null) {
      int lastPictureUpdate = 0;
      final isBot = author!.isBot ?? author!.is_bot ?? false;
      if (isBot) {
        lastPictureUpdate = author!.props?.bot_last_icon_update ?? author!.bot_last_icon_update ?? 0;
      } else {
        lastPictureUpdate = author!.lastPictureUpdate ?? author!.last_picture_update ?? 0;
      }

      final pictureUrl = client.getProfilePictureUrl(author!.id, lastPictureUpdate);
      final imgSource = source ?? {'uri': '$serverUrl$pictureUrl'};
      if (imgSource['uri']?.startsWith('file://') ?? false) {
        return AnimatedImage(
          key: ValueKey(pictureUrl),
          ref: forwardRef,
          style: fIStyle,
          source: imgSource['uri'],
        );
      }
      return AnimatedFastImage(
        key: ValueKey(pictureUrl),
        ref: forwardRef,
        style: fIStyle,
        source: imgSource,
      );
    }
    return CompassIcon(
      name: ACCOUNT_OUTLINE_IMAGE,
      size: iconSize ?? size,
      style: TextStyle(color: changeOpacity(theme.centerChannelColor, 0.48)),
    );
  }

  TextStyle getStyleSheet(ThemeData theme) {
    return TextStyle(
      color: changeOpacity(theme.centerChannelColor, 0.48),
    );
  }
}

class AnimatedImage extends StatelessWidget {
  final Key? key;
  final GlobalKey? ref;
  final BoxDecoration style;
  final String source;

  AnimatedImage({this.key, this.ref, required this.style, required this.source});

  @override
  Widget build(BuildContext context) {
    return Image.network(
      source,
      key: key,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        return AnimatedSwitcher(
          duration: Duration(milliseconds: 300),
          child: frame == null ? CircularProgressIndicator() : child,
        );
      },
    );
  }
}

class AnimatedFastImage extends StatelessWidget {
  final Key? key;
  final GlobalKey? ref;
  final BoxDecoration style;
  final dynamic source;

  AnimatedFastImage({this.key, this.ref, required this.style, required this.source});

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: source['uri'],
      key: key,
      placeholder: (context, url) => CircularProgressIndicator(),
      errorWidget: (context, url, error) => Icon(Icons.error),
    );
  }
}