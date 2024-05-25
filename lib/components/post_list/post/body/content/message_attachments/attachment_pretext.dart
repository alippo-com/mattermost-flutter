// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:mattermost_flutter/components/markdown.dart';
import 'package:mattermost_flutter/types/markdown_block_styles.dart';
import 'package:mattermost_flutter/types/markdown_text_styles.dart';
import 'package:mattermost_flutter/types/theme.dart';
import 'package:mattermost_flutter/types/post_metadata.dart';

class AttachmentPreText extends StatelessWidget {
  final TextStyle baseTextStyle;
  final MarkdownBlockStyles? blockStyles;
  final String channelId;
  final String location;
  final PostMetadata? metadata;
  final MarkdownTextStyles? textStyles;
  final Theme theme;
  final String? value;

  AttachmentPreText({
    required this.baseTextStyle,
    this.blockStyles,
    required this.channelId,
    required this.location,
    this.metadata,
    this.textStyles,
    required this.theme,
    this.value,
  });

  @override
  Widget build(BuildContext context) {
    if (value == null) {
      return Container();
    }

    return Container(
      margin: EdgeInsets.only(top: 5),
      child: Markdown(
        baseTextStyle: baseTextStyle,
        channelId: channelId,
        textStyles: textStyles,
        blockStyles: blockStyles,
        disableGallery: true,
        imagesMetadata: metadata?.images,
        location: location,
        theme: theme,
        value: value!,
      ),
    );
  }
}
