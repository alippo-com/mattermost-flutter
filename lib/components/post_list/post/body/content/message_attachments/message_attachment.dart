
import 'package:flutter/material.dart';
import 'package:mattermost_flutter/utils/markdown.dart';
import 'package:mattermost_flutter/utils/message_attachment_colors.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/url.dart';
import 'package:mattermost_flutter/components/post_list/post/body/content/message_attachments/attachment_actions.dart';
import 'package:mattermost_flutter/components/post_list/post/body/content/message_attachments/attachment_author.dart';
import 'package:mattermost_flutter/components/post_list/post/body/content/message_attachments/attachment_fields.dart';
import 'package:mattermost_flutter/components/post_list/post/body/content/message_attachments/attachment_footer.dart';
import 'package:mattermost_flutter/components/post_list/post/body/content/message_attachments/attachment_image.dart';
import 'package:mattermost_flutter/components/post_list/post/body/content/message_attachments/attachment_pretext.dart';
import 'package:mattermost_flutter/components/post_list/post/body/content/message_attachments/attachment_text.dart';
import 'package:mattermost_flutter/components/post_list/post/body/content/message_attachments/attachment_thumbnail.dart';
import 'package:mattermost_flutter/components/post_list/post/body/content/message_attachments/attachment_title.dart';

class MessageAttachment extends StatelessWidget {
  final MessageAttachmentModel attachment;
  final String channelId;
  final double? layoutWidth;
  final String location;
  final PostMetadata? metadata;
  final String postId;
  final ThemeModel theme;

  MessageAttachment({
    required this.attachment,
    required this.channelId,
    this.layoutWidth,
    required this.location,
    this.metadata,
    required this.postId,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final style = getStyleSheet(theme);
    final blockStyles = getMarkdownBlockStyles(theme);
    final textStyles = getMarkdownTextStyles(theme);
    final STATUS_COLORS = getStatusColors(theme);
    Map<String, Color>? borderStyle;
    if (attachment.color != null) {
      if (attachment.color!.startsWith('#')) {
        borderStyle = {'borderLeftColor': Color(int.parse(attachment.color!.substring(1, 7), radix: 16) + 0xFF000000)};
      } else if (STATUS_COLORS[attachment.color!] != null) {
        borderStyle = {'borderLeftColor': STATUS_COLORS[attachment.color!]};
      }
    }

    return Column(
      children: [
        if (attachment.pretext != null)
          AttachmentPreText(
            baseTextStyle: style.message,
            blockStyles: blockStyles,
            channelId: channelId,
            location: location,
            metadata: metadata,
            textStyles: textStyles,
            theme: theme,
            value: attachment.pretext,
          ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(color: changeOpacity(theme.centerChannelColor, 0.15)),
              right: BorderSide(color: changeOpacity(theme.centerChannelColor, 0.15)),
              top: BorderSide(color: changeOpacity(theme.centerChannelColor, 0.15)),
              left: borderStyle != null ? BorderSide(color: borderStyle['borderLeftColor']!) : BorderSide.none,
            ),
          ),
          margin: EdgeInsets.only(top: 5),
          padding: EdgeInsets.all(12),
          child: Column(
            children: [
              if (attachment.author_icon != null || attachment.author_name != null)
                AttachmentAuthor(
                  icon: attachment.author_icon,
                  link: attachment.author_link,
                  name: attachment.author_name,
                  theme: theme,
                ),
              if (attachment.title != null)
                AttachmentTitle(
                  channelId: channelId,
                  location: location,
                  link: attachment.title_link,
                  theme: theme,
                  value: attachment.title,
                ),
              if (isValidUrl(attachment.thumb_url))
                AttachmentThumbnail(uri: attachment.thumb_url!),
              if (attachment.text != null)
                AttachmentText(
                  baseTextStyle: style.message,
                  blockStyles: blockStyles,
                  channelId: channelId,
                  location: location,
                  hasThumbnail: attachment.thumb_url != null,
                  metadata: metadata,
                  textStyles: textStyles,
                  value: attachment.text,
                  theme: theme,
                ),
              if (attachment.fields != null && attachment.fields!.isNotEmpty)
                AttachmentFields(
                  baseTextStyle: style.message,
                  blockStyles: blockStyles,
                  channelId: channelId,
                  location: location,
                  fields: attachment.fields!,
                  metadata: metadata,
                  textStyles: textStyles,
                  theme: theme,
                ),
              if (attachment.footer != null)
                AttachmentFooter(
                  icon: attachment.footer_icon,
                  text: attachment.footer,
                  theme: theme,
                ),
              if (attachment.actions != null && attachment.actions!.isNotEmpty)
                AttachmentActions(
                  actions: attachment.actions!,
                  postId: postId,
                  theme: theme,
                ),
              if (metadata != null && metadata!.images != null && metadata!.images![attachment.image_url] != null)
                AttachmentImage(
                  imageUrl: attachment.image_url!,
                  imageMetadata: metadata!.images![attachment.image_url]!,
                  layoutWidth: layoutWidth,
                  location: location,
                  postId: postId,
                  theme: theme,
                ),
            ],
          ),
        ),
      ],
    );
  }

  Map<String, dynamic> getStyleSheet(ThemeModel theme) {
    return {
      'container': {
        'borderBottomColor': changeOpacity(theme.centerChannelColor, 0.15),
        'borderRightColor': changeOpacity(theme.centerChannelColor, 0.15),
        'borderTopColor': changeOpacity(theme.centerChannelColor, 0.15),
        'borderBottomWidth': 1.0,
        'borderRightWidth': 1.0,
        'borderTopWidth': 1.0,
        'marginTop': 5.0,
        'padding': 12.0,
      },
      'border': {
        'borderLeftColor': changeOpacity(theme.linkColor, 0.6),
        'borderLeftWidth': 3.0,
      },
      'message': {
        'color': theme.centerChannelColor,
        'fontSize': 15.0,
        'lineHeight': 20.0,
      },
    };
  }
}
