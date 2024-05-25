import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:commonmark/commonmark.dart';
import 'package:mattermost_flutter/components/emoji.dart';
import 'package:mattermost_flutter/utils/markdown.dart';
import 'package:mattermost_flutter/components/at_mention.dart';
import 'package:mattermost_flutter/types/global/markdown.dart';

class RemoveMarkdown extends StatelessWidget {
  final bool? enableEmoji;
  final bool? enableCodeSpan;
  final bool? enableHardBreak;
  final bool? enableSoftBreak;
  final TextStyle? baseStyle;
  final MarkdownTextStyles? textStyle;
  final String value;

  const RemoveMarkdown({
    this.enableEmoji,
    this.enableCodeSpan,
    this.enableHardBreak,
    this.enableSoftBreak,
    this.baseStyle,
    this.textStyle,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final renderEmoji = useCallback((MarkdownEmojiRenderer emojiRenderer) {
      if (enableEmoji == null || !enableEmoji!) {
        return renderText(emojiRenderer.literal);
      }

      return Emoji(
        emojiName: emojiRenderer.emojiName,
        literal: emojiRenderer.literal,
        textStyle: baseStyle,
      );
    });

    final renderBreak = useCallback(() => '\n');

    final renderText = useCallback((String literal) {
      return Text(literal, style: baseStyle);
    });

    final renderAtMention = (String context, String mentionName) {
      return AtMention(
        textStyle: computeTextStyle(textStyle, baseStyle, context),
        mentionName: mentionName,
      );
    };

    final renderCodeSpan = useCallback((MarkdownBaseRenderer renderer) {
      if (enableCodeSpan == null || !enableCodeSpan!) {
        return renderText(renderer.literal);
      }

      final code = textStyle?.code;
      return Text(
        renderer.literal,
        style: computeTextStyle(textStyle, [baseStyle, code], renderer.context),
      );
    });

    final renderNull = () => null;

    final createRenderer = () {
      return Renderer({
        'text': renderText,
        'emph': Renderer.forwardChildren,
        'strong': Renderer.forwardChildren,
        'del': Renderer.forwardChildren,
        'code': renderCodeSpan,
        'link': Renderer.forwardChildren,
        'image': renderNull,
        'atMention': renderAtMention,
        'channelLink': Renderer.forwardChildren,
        'emoji': renderEmoji,
        'hashtag': Renderer.forwardChildren,
        'latexinline': Renderer.forwardChildren,
        'paragraph': Renderer.forwardChildren,
        'heading': Renderer.forwardChildren,
        'codeBlock': renderNull,
        'blockQuote': renderNull,
        'list': renderNull,
        'item': renderNull,
        'hardBreak': enableHardBreak == true ? renderBreak : renderNull,
        'thematicBreak': renderNull,
        'softBreak': enableSoftBreak == true ? renderBreak : renderNull,
        'htmlBlock': renderNull,
        'htmlInline': renderNull,
        'table': renderNull,
        'table_row': renderNull,
        'table_cell': renderNull,
        'mention_highlight': Renderer.forwardChildren,
        'editedIndicator': Renderer.forwardChildren,
      });
    };

    final parser = Parser();
    final renderer = useMemo(createRenderer, [renderText, renderEmoji]);
    final ast = parser.parse(value);

    return renderer.render(ast);
  }
}
