// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:mattermost_flutter/types/message_attachment.dart';
import 'package:mattermost_flutter/types/post_metadata.dart';
import 'package:mattermost_flutter/types/theme.dart';

class MessageAttachments extends StatelessWidget {
  final List<MessageAttachment> attachments;
  final String channelId;
  final double? layoutWidth;
  final String location;
  final PostMetadata? metadata;
  final String postId;
  final Theme theme;

  const MessageAttachments({
    Key? key,
    required this.attachments,
    required this.channelId,
    this.layoutWidth,
    required this.location,
    this.metadata,
    required this.postId,
    required this.theme,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> content = [];

    for (int i = 0; i < attachments.length; i++) {
      content.add(
        MessageAttachmentWidget(
          attachment: attachments[i],
          channelId: channelId,
          key: Key('att_$i'),
          layoutWidth: layoutWidth,
          location: location,
          metadata: metadata,
          postId: postId,
          theme: theme,
        ),
      );
    }

    return Column(
      children: content,
    );
  }
}
