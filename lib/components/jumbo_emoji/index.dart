import 'package:flutter/material.dart';
import 'package:mattermost_flutter/components/emoji.dart';
import 'package:mattermost_flutter/components/formatted_text.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:flutter/foundation.dart';

class JumboEmoji extends StatelessWidget {
  final TextStyle baseTextStyle;
  final bool? isEdited;
  final String value;

  JumboEmoji({
    required this.baseTextStyle,
    this.isEdited,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = useTheme();
    final style = getStyleSheet(theme);

    Widget renderEmoji({required String emojiName, required String literal}) {
      return Container(
        child: Emoji(
          emojiName: emojiName,
          literal: literal,
          testID: 'markdown_emoji',
          textStyle: baseTextStyle.merge(style['jumboEmoji']),
        ),
      );
    }

    Widget renderParagraph({required Widget children}) {
      return Container(
        alignment: Alignment.centerLeft,
        child: Row(
          children: [
            Text(
              '',
              style: baseTextStyle,
            ),
            children,
          ],
        ),
      );
    }

    Widget renderText({required String literal}) {
      return renderEmoji(emojiName: literal, literal: literal);
    }

    Widget renderNewLine() {
      return Text(
        '\n',
        style: baseTextStyle.merge(style['newLine']),
      );
    }

    Widget renderEditedIndicator({required List<String> context}) {
      String spacer = '';
      if (context.isNotEmpty && context[0] == 'paragraph') {
        spacer = ' ';
      }

      final styles = baseTextStyle.merge(style['editedIndicatorText']);

      return Text(
        '$spacer(edited)',
        style: styles,
        key: Key('edited_indicator'),
      );
    }

    final parser = MarkdownParser();
    final renderer = MarkdownRenderer(
      renderParagraph: renderParagraph,
      renderText: renderText,
      renderNewLine: renderNewLine,
      renderEditedIndicator: renderEditedIndicator,
    );
    final ast = parser.parse(value.replaceAll(RegExp(r'\n*$'), ''));

    if (isEdited ?? false) {
      final editIndicatorNode = MarkdownNode(type: 'edited_indicator');
      if (ast.isNotEmpty && ['heading', 'paragraph'].contains(ast.last.type)) {
        ast.add(editIndicatorNode);
      } else {
        final node = MarkdownNode(type: 'paragraph');
        node.add(editIndicatorNode);
        ast.add(node);
      }
    }

    return renderer.render(ast);
  }

  Map<String, TextStyle> getStyleSheet(ThemeData theme) {
    final editedOpacity = defaultTargetPlatform == TargetPlatform.iOS ? 0.3 : 1.0;
    final editedColor = defaultTargetPlatform == TargetPlatform.iOS
        ? theme.colorScheme.onSurface
        : blendColors(theme.colorScheme.surface, theme.colorScheme.onSurface, 0.3);

    return {
      'block': TextStyle(
        fontSize: 16,
      ),
      'editedIndicatorText': TextStyle(
        color: editedColor,
        opacity: editedOpacity,
      ),
      'jumboEmoji': TextStyle(
        fontSize: 50,
        height: 60,
      ),
      'newLine': TextStyle(
        height: 60,
      ),
    };
  }
}