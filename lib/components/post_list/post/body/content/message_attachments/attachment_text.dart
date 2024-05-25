// Dart Code
// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mattermost_flutter/components/markdown.dart';
import 'package:mattermost_flutter/components/post_list/post/body/message/show_more_button.dart';
import 'package:mattermost_flutter/hooks/show_more.dart';
import 'package:mattermost_flutter/types/global/markdown.dart';
import 'package:mattermost_flutter/types/theme.dart';

class AttachmentText extends StatefulWidget {
  final TextStyle baseTextStyle;
  final MarkdownBlockStyles? blockStyles;
  final String channelId;
  final bool? hasThumbnail;
  final String location;
  final PostMetadata? metadata;
  final MarkdownTextStyles? textStyles;
  final Theme theme;
  final String? value;

  const AttachmentText({
    Key? key,
    required this.baseTextStyle,
    this.blockStyles,
    required this.channelId,
    this.hasThumbnail,
    required this.location,
    this.metadata,
    this.textStyles,
    required this.theme,
    this.value,
  }) : super(key: key);

  @override
  _AttachmentTextState createState() => _AttachmentTextState();
}

class _AttachmentTextState extends State<AttachmentText> {
  bool open = false;
  double? height;
  late double maxHeight;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        maxHeight = (MediaQuery.of(context).size.height * 0.4) + 54;
      });
    });
  }

  void _onLayout(Size size) {
    setState(() {
      height = size.height;
    });
  }

  void _onPress() {
    setState(() {
      open = !open;
    });
  }

  @override
  Widget build(BuildContext context) {
    final animatedStyle = useShowMoreAnimatedStyle(height, maxHeight, open);

    return Container(
      padding: widget.hasThumbnail == true ? EdgeInsets.only(right: 12) : null,
      child: Column(
        children: [
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            height: height != null && height! > maxHeight ? maxHeight : null,
            child: SingleChildScrollView(
              physics: NeverScrollableScrollPhysics(),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _onLayout(constraints.biggest);
                  });
                  return Markdown(
                    channelId: widget.channelId,
                    location: widget.location,
                    baseTextStyle: widget.baseTextStyle,
                    textStyles: widget.textStyles,
                    blockStyles: widget.blockStyles,
                    disableGallery: true,
                    imagesMetadata: widget.metadata?.images,
                    value: widget.value,
                    theme: widget.theme,
                  );
                },
              ),
            ),
          ),
          if (height != null && height! > maxHeight)
            ShowMoreButton(
              highlight: false,
              theme: widget.theme,
              showMore: !open,
              onPressed: _onPress,
            ),
        ],
      ),
    );
  }
}
