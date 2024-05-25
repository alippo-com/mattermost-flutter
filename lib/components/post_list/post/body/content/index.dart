// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';

import 'package:mattermost_flutter/utils/url.dart';
'import 'embedded_bindings.dart';
'import 'image_preview.dart';
'import 'message_attachments.dart';
'import 'opengraph.dart';
'import 'youtube.dart';

'import 'package:mattermost_flutter/types/post_model.dart';
'import 'package:mattermost_flutter/types/theme.dart';

'class Content extends StatelessWidget {
  final bool isReplyPost;
  final double? layoutWidth;
  final String location;
  final PostModel post;
  final Theme theme;

  const Content({
    Key? key,
    required this.isReplyPost,
    this.layoutWidth,
    required this.location,
    required this.post,
    required this.theme,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String? type = post.metadata?.embeds?.first.type;
    if (type == null && post.props?.appBindings?.isNotEmpty == true) {
      type = 'app_bindings';
    }

    if (type == null) {
      return Container();
    }

    switch (type) {
      case 'image':
        return ImagePreview(
          isReplyPost: isReplyPost,
          layoutWidth: layoutWidth,
          location: location,
          metadata: post.metadata,
          postId: post.id,
          theme: theme,
        );
      case 'opengraph':
        if (isYoutubeLink(post.metadata!.embeds!.first.url)) {
          return YouTube(
            isReplyPost: isReplyPost,
            layoutWidth: layoutWidth,
            metadata: post.metadata,
          );
        }

        return Opengraph(
          isReplyPost: isReplyPost,
          layoutWidth: layoutWidth,
          location: location,
          metadata: post.metadata,
          postId: post.id,
          removeLinkPreview: post.props?.removeLinkPreview == 'true',
          theme: theme,
        );
      case 'message_attachment':
        if (post.props.attachments?.isNotEmpty == true) {
          return MessageAttachments(
            attachments: post.props.attachments!,
            channelId: post.channelId,
            layoutWidth: layoutWidth,
            location: location,
            metadata: post.metadata,
            postId: post.id,
            theme: theme,
          );
        }
        break;
      case 'app_bindings':
        if (post.props.appBindings?.isNotEmpty == true) {
          return EmbeddedBindings(
            location: location,
            post: post,
            theme: theme,
          );
        }
        break;
    }

    return Container();
  }
}