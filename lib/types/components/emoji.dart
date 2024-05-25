// Converted Dart content based on the provided TypeScript file

// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:mattermost_flutter/types/database/models/servers/custom_emoji.dart';
import 'package:mattermost_flutter/types/global/styles.dart';
import 'package:flutter/widgets.dart';

class ImageStyleUniques extends ImageStyles {
  // Define properties excluding those in TextStyle
  double? width;
  double? height;
  // Exclude properties that are part of TextStyle
}

class EmojiCommonStyle extends ImageStyles {
  // Define properties excluding those in ImageStyleUniques
  double? width;
  double? height;
  double? borderWidth;
  // Exclude properties that are part of ImageStyleUniques
}

class EmojiProps {
  final String emojiName;
  final bool? displayTextOnly;
  final String? literal;
  final double? size;
  final TextStyle? textStyle;
  final ImageStyles? imageStyle;
  final EmojiCommonStyle? commonStyle;
  final List<CustomEmojiModel> customEmojis;
  final String? testID;

  EmojiProps({
    required this.emojiName,
    this.displayTextOnly,
    this.literal,
    this.size,
    this.textStyle,
    this.imageStyle,
    this.commonStyle,
    required this.customEmojis,
    this.testID,
  });
}

typedef EmojiComponent = Widget Function(EmojiProps props);
