// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:mattermost_flutter/components/compass_icon.dart';

class MarkdownBlockQuote extends StatelessWidget {
  final bool? continueBlock;
  final TextStyle? iconStyle;
  final List<Widget> children;

  MarkdownBlockQuote({this.continueBlock, this.iconStyle, required this.children});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (continueBlock == null || !continueBlock!)
          Container(
            width: 23,
            child: CompassIcon(
              name: 'format-quote-open',
              style: iconStyle,
              size: 20,
            ),
          ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ],
    );
  }
}
