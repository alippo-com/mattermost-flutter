// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.


import 'package:flutter/material.dart';
import 'package:mattermost_flutter/components/compass_icon.dart';
import 'package:mattermost_flutter/components/emoji.dart';
import 'package:mattermost_flutter/components/formatted_text.dart';
import 'package:mattermost_flutter/utils/markdown.dart';
import 'package:mattermost_flutter/utils/theme.dart';

import 'channel_mention.dart';
import 'markdown_code_block.dart';
import 'markdown_image.dart';
import 'markdown_latex_inline.dart';
import 'markdown_link.dart';
import 'markdown_list.dart';
import 'markdown_list_item.dart';
import 'markdown_table.dart';
import 'markdown_table_cell.dart';
import 'markdown_table_image.dart';
import 'markdown_table_row.dart';
import 'transform.dart';

import 'package:commonmark/commonmark.dart';

class Markdown extends StatelessWidget {
  final List<String>? autolinkedUrlSchemes;
  final TextStyle baseTextStyle;
  final TextStyle? baseParagraphStyle;
  final MarkdownBlockStyles? blockStyles;
  final String? channelId;
  final ChannelMentions? channelMentions;
  final bool disableAtChannelMentionHighlight;
  final bool disableAtMentions;
  final bool disableBlockQuote;
  final bool disableChannelLink;
  final bool disableCodeBlock;
  final bool disableGallery;
  final bool disableHashtags;
  final bool disableHeading;
  final bool disableQuotes;
  final bool disableTables;
  final bool enableLatex;
  final bool enableInlineLatex;
  final List<HighlightWithoutNotificationKey>? highlightKeys;
  final Map<String, PostImage?>? imagesMetadata;
  final bool isEdited;
  final bool isReplyPost;
  final bool isSearchResult;
  final double? layoutHeight;
  final double? layoutWidth;
  final String location;
  final int maxNodes;
  final List<UserMentionKey>? mentionKeys;
  final int? minimumHashtagLength;
  final void Function(TapDownDetails)? onPostPress;
  final String? postId;
  final List<SearchPattern>? searchPatterns;
  final MarkdownTextStyles? textStyles;
  final Theme theme;
  final String? value;
  final void Function(String)? onLinkLongPress;
  final bool isUnsafeLinksPost;

  Markdown({
    this.autolinkedUrlSchemes,
    required this.baseTextStyle,
    this.baseParagraphStyle,
    this.blockStyles,
    this.channelId,
    this.channelMentions,
    this.disableAtChannelMentionHighlight = false,
    this.disableAtMentions = false,
    this.disableBlockQuote = false,
    this.disableChannelLink = false,
    this.disableCodeBlock = false,
    this.disableGallery = false,
    this.disableHashtags = false,
    this.disableHeading = false,
    this.disableQuotes = false,
    this.disableTables = false,
    this.enableLatex = false,
    this.enableInlineLatex = false,
    this.highlightKeys,
    this.imagesMetadata,
    this.isEdited = false,
    this.isReplyPost = false,
    this.isSearchResult = false,
    this.layoutHeight,
    this.layoutWidth,
    required this.location,
    required this.maxNodes,
    this.mentionKeys,
    this.minimumHashtagLength,
    this.onPostPress,
    this.postId,
    this.searchPatterns,
    this.textStyles,
    required this.theme,
    this.value,
    this.onLinkLongPress,
    this.isUnsafeLinksPost = false,
  });

  @override
  Widget build(BuildContext context) {
    final style = _getStyleSheet(theme);
    final managedConfig = useManagedConfig<ManagedConfig>();

    final urlFilter = (String url) {
      final scheme = getScheme(url);
      return scheme == null || autolinkedUrlSchemes?.contains(scheme) == true;
    };

    final renderAtMention = (MarkdownAtMentionRenderer args) {
      if (disableAtMentions) {
        return _renderText(MarkdownBaseRenderer(context: args.context, literal: '@${args.mentionName}'));
      }
      final computedStyles = computeTextStyle(textStyles!, baseTextStyle, args.context);
      final fontFamily = computedStyles.fontFamily;
      final fontSize = computedStyles.fontSize;
      final fontWeight = computedStyles.fontWeight;

      return AtMention(
        channelId: channelId,
        disableAtChannelMentionHighlight: disableAtChannelMentionHighlight,
        mentionStyle: textStyles?.mention?.copyWith(fontSize: fontSize, fontWeight: fontWeight, fontFamily: fontFamily),
        textStyle: computedStyles.copyWith(opacity: 1),
        isSearchResult: isSearchResult,
        location: location,
        mentionName: args.mentionName,
        onPostPress: onPostPress,
        mentionKeys: mentionKeys,
      );
    };

    // Other render functions follow a similar pattern...

    final parser = CommonMarkParser(
      urlFilter: urlFilter,
      minimumHashtagLength: minimumHashtagLength ?? 3,
    );

    final renderer = MarkdownRenderer(
      renderParagraphsInLists: true,
      maxNodes: maxNodes,
      getExtraPropsForNode: _getExtraPropsForNode,
      allowedTypes: MarkdownRenderer.defaultAllowedTypes,
      theme: theme,
      textStyles: textStyles,
    );

    var ast = parser.parse(value ?? '');
    ast = combineTextNodes(ast);
    ast = addListItemIndices(ast);
    ast = pullOutImages(ast);
    ast = parseTaskLists(ast);

    if (mentionKeys != null) {
      ast = highlightMentions(ast, mentionKeys!);
    }
    if (highlightKeys != null) {
      ast = highlightWithoutNotification(ast, highlightKeys!);
    }
    if (searchPatterns != null) {
      ast = highlightSearchPatterns(ast, searchPatterns!);
    }
    if (isEdited) {
      if (ast.lastChild != null && (ast.lastChild!.type == 'heading' || ast.lastChild!.type == 'paragraph')) {
        ast.appendChild(MarkdownNode('edited_indicator'));
      } else {
        final node = MarkdownNode('paragraph');
        node.appendChild(MarkdownNode('edited_indicator'));
        ast.appendChild(node);
      }
    }

    return renderer.render(ast);
  }

  _getStyleSheet(Theme theme) {
    return {
      'block': TextStyle(
        color: theme.centerChannelColor,
        backgroundColor: theme.centerChannelBg,
      ),
      'editedIndicatorText': TextStyle(
        color: theme.centerChannelColor,
        opacity: Platform.isIOS ? 0.3 : 1.0,
      ),
      'maxNodesWarning': TextStyle(
        color: theme.errorTextColor,
      ),
      'atMentionOpacity': TextStyle(
        opacity: 1,
      ),
      'bold': TextStyle(
        fontWeight: FontWeight.w600,
      ),
    };
  }

  _getExtraPropsForNode(MarkdownNode node) {
    return {
      'continue': node.continue,
      'index': node.index,
      'reactChildren': node.reactChildren,
      'linkDestination': node.linkDestination,
      'size': node.size,
      'isChecked': node.isChecked,
    };
  };

  _renderText(MarkdownBaseRenderer args) {
    final selectable = managedConfig.copyAndPasteProtection != 'true' && args.context.contains('table_cell');
    if (args.context.contains('image')) {
      // If this text is displayed, it will be styled by the image component
      return Text(
        args.literal,
        textAlign: TextAlign.start,
        textDirection: TextDirection.ltr,
      );
    }

    var styles = computeTextStyle(textStyles!, baseTextStyle, args.context);
    if (disableHeading) {
      styles = computeTextStyle(textStyles!, baseTextStyle, args.context.where((c) => !c.startsWith('heading')).toList());
    }

    if (args.context.contains('mention_highlight')) {
      styles = styles.copyWith(backgroundColor: theme.mentionHighlightBg);
    }

    return Text(
      args.literal,
      style: styles,
      textAlign: TextAlign.start,
      textDirection: TextDirection.ltr,
      key: ValueKey(args.literal),
    );
  }
}
