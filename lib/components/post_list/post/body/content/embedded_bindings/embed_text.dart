
// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'markdown.dart'; // Assuming you have a markdown widget
import 'show_more_button.dart'; // Assuming you have a show more button widget
import 'theme.dart'; // Assuming you have a theme utility
import 'markdown_utils.dart'; // Assuming you have markdown utility functions

class EmbedText extends StatefulWidget {
  final String channelId;
  final String location;
  final Theme theme;
  final String value;

  const EmbedText({
    Key? key,
    required this.channelId,
    required this.location,
    required this.theme,
    required this.value,
  }) : super(key: key);

  @override
  _EmbedTextState createState() => _EmbedTextState();
}

class _EmbedTextState extends State<EmbedText> {
  bool open = false;
  double? height;
  final double showMoreHeight = 54;
  
  @override
  Widget build(BuildContext context) {
    final dimensions = MediaQuery.of(context).size;
    final maxHeight = (dimensions.height * 0.4) + showMoreHeight;
    
    final blockStyles = getMarkdownBlockStyles(widget.theme);
    final textStyles = getMarkdownTextStyles(widget.theme);
    final style = getStyles(widget.theme);

    return Column(
      children: [
        AnimatedContainer(
          duration: Duration(milliseconds: 300),
          height: open ? height : maxHeight,
          child: SingleChildScrollView(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return GestureDetector(
                  onTap: () => setState(() => height = constraints.maxHeight),
                  child: Markdown(
                    baseTextStyle: style.message,
                    channelId: widget.channelId,
                    location: widget.location,
                    textStyles: textStyles,
                    blockStyles: blockStyles,
                    disableGallery: true,
                    theme: widget.theme,
                    value: widget.value,
                  ),
                );
              },
            ),
          ),
        ),
        if ((height ?? 0) > maxHeight)
          ShowMoreButton(
            highlight: false,
            theme: widget.theme,
            showMore: !open,
            onPress: () => setState(() => open = !open),
          ),
      ],
    );
  }

  TextStyle getStyles(Theme theme) {
    return TextStyle(
      color: theme.centerChannelColor,
      fontSize: 15,
      height: 20,
    );
  }
}
