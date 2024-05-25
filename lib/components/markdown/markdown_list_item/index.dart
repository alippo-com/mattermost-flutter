
// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:mattermost_flutter/types.dart';

class MarkdownListItem extends StatelessWidget {
  final TextStyle bulletStyle;
  final double bulletWidth;
  final List<Widget> children;
  final bool continueList;
  final int index;
  final bool ordered;
  final int level;

  MarkdownListItem({
    required this.bulletStyle,
    required this.bulletWidth,
    required this.children,
    required this.continueList,
    required this.index,
    required this.ordered,
    required this.level,
  });

  @override
  Widget build(BuildContext context) {
    String bullet;
    if (continueList) {
      bullet = '';
    } else if (ordered) {
      bullet = '${index + 1}.';
    } else if (level % 2 == 0) {
      bullet = '◦';
    } else {
      bullet = '•';
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: bulletWidth,
          alignment: Alignment.centerRight,
          margin: EdgeInsets.only(right: 5),
          child: Text(
            bullet,
            style: bulletStyle,
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
