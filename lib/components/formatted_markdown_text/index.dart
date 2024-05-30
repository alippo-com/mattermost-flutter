
// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:mattermost_flutter/components/markdown/markdown_link.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/log.dart';
import 'package:mattermost_flutter/utils/markdown.dart';
import 'package:mattermost_flutter/utils/theme_utils.dart';
import 'package:provider/provider.dart';
import 'package:react_intl/intl.dart';

import 'package:mattermost_flutter/types/primitive_type.dart'; // For PrimitiveType

class FormattedMarkdownText extends StatelessWidget {
  final TextStyle? baseTextStyle;
  final String? channelId;
  final String defaultMessage;
  final String id;
  final String location;
  final void Function()? onPostPress;
  final TextStyle? style;
  final Map<String, PrimitiveType>? values;

  const FormattedMarkdownText({
    Key? key,
    this.baseTextStyle,
    this.channelId,
    required this.defaultMessage,
    required this.id,
    required this.location,
    this.onPostPress,
    this.style,
    this.values,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final intl = Intl.of(context);
    final theme = Provider.of<Theme>(context);
    final styles = _getStyleSheet(theme);
    final messageDescriptor = MessageDescriptor(id: id, defaultMessage: defaultMessage);
    final message = intl.formatMessage(messageDescriptor, values);
    final txtStyles = getMarkdownTextStyles(theme);

    Widget _renderAtMention(String mentionName, List<String> context) {
      return AtMention(
        channelId: channelId,
        mentionStyle: txtStyles.mention,
        mentionName: mentionName,
        location: location,
        onPostPress: onPostPress,
        textStyle: [computeTextStyle(baseTextStyle, context), styles.atMentionOpacity],
      );
    }

    Text _renderBreak() {
      return Text('
');
    }

    Text _renderCodeSpan(String literal, List<String> context) {
      final computed = computeTextStyle([styles.message, txtStyles.code], context);
      return Text(literal, style: computed);
    }

    Widget _renderHTML(String id, dynamic props) {
      logWarning('HTML used in FormattedMarkdownText component with id $id');
      return _renderText(props);
    }

    Widget _renderLink(String href, Widget children) {
      final url = href.startsWith(TARGET_BLANK_URL_PREFIX) ? href.substring(1) : href;
      return MarkdownLink(href: url, child: children);
    }

    Widget _renderParagraph(Widget children, bool first) {
      final blockStyle = [styles.block];
      if (!first) {
        final blockS = getMarkdownBlockStyles(theme);
        blockStyle.add(blockS.adjacentParagraph);
      }
      return Text(children, style: blockStyle);
    }

    Text _renderText(String literal, List<String> context) {
      final computed = computeTextStyle(style ?? styles.message, context);
      return Text(literal, style: computed);
    }

    final parser = MarkdownParser();
    final ast = parser.parse(message);

    return MarkdownBody(
      data: message,
      selectable: false,
      styleSheet: MarkdownStyleSheet(
        p: _renderParagraph,
        code: (code) => _renderCodeSpan(code, []),
        a: (href, text) => _renderLink(href, text),
        atMention: (mentionName) => _renderAtMention(mentionName, []),
      ),
    );
  }

  TextStyle computeTextStyle(TextStyle? base, List<String> context) {
    return concatStyles(base, context.map((type) => txtStyles[type]));
  }

  Map<String, TextStyle> _getStyleSheet(Theme theme) {
    return {
      'block': TextStyle(
        alignItems: AlignmentDirectional.topStart,
        flexDirection: Axis.horizontal,
        flexWrap: WrapAlignment.start,
      ),
      'message': TextStyle(
        color: changeOpacity(theme.centerChannelColor, 0.8),
        fontSize: 16,
        height: 20,
      ),
      'atMentionOpacity': TextStyle(
        opacity: 1,
      ),
    };
  }
}
