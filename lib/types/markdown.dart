// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/widgets.dart';

class SearchPattern {
  final RegExp pattern;
  final String term;

  SearchPattern({required this.pattern, required this.term});
}

class UserMentionKey {
  final String key;
  final bool caseSensitive;

  UserMentionKey({required this.key, this.caseSensitive = false});
}

class HighlightWithoutNotificationKey {
  final String key;

  HighlightWithoutNotificationKey({required this.key});
}

class MarkdownBlockStyles {
  final BoxDecoration adjacentParagraph;
  final BoxDecoration horizontalRule;
  final TextStyle quoteBlockIcon;

  MarkdownBlockStyles({
    required this.adjacentParagraph,
    required this.horizontalRule,
    required this.quoteBlockIcon,
  });
}

class MarkdownTextStyles {
  final Map<String, TextStyle> styles;

  MarkdownTextStyles({required this.styles});
}

class MarkdownAtMentionRenderer {
  final List<String> context;
  final String mentionName;

  MarkdownAtMentionRenderer({required this.context, required this.mentionName});
}

class MarkdownBaseRenderer {
  final List<String> context;
  final String literal;

  MarkdownBaseRenderer({required this.context, required this.literal});
}

class MarkdownChannelMentionRenderer {
  final List<String> context;
  final String channelName;

  MarkdownChannelMentionRenderer({required this.context, required this.channelName});
}

class MarkdownEmojiRenderer extends MarkdownBaseRenderer {
  final String emojiName;

  MarkdownEmojiRenderer({required String context, required String literal, required this.emojiName}) : super(context: context, literal: literal);
}

class MarkdownImageRenderer {
  final String? linkDestination;
  final List<String> context;
  final String src;
  final Size? size;

  MarkdownImageRenderer({this.linkDestination, required this.context, required this.src, this.size});
}

class MarkdownLatexRenderer extends MarkdownBaseRenderer {
  final String latexCode;

  MarkdownLatexRenderer({required String context, required String literal, required this.latexCode}) : super(context: context, literal: literal);
}
