// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:mattermost_flutter/types/theme.dart'; // Your custom theme type
import 'package:mattermost_flutter/utils/theme.dart'; // Your utility functions for theme
import 'package:cached_network_image/cached_network_image.dart'; // Equivalent of FastImage

class AttachmentFooter extends StatelessWidget {
  final String? icon;
  final String text;
  final Theme theme;

  AttachmentFooter({
    required this.text,
    required this.theme,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final style = getStyleSheet(theme);

    return Container(
      margin: EdgeInsets.only(top: 5),
      child: Row(
        children: <Widget>[
          if (icon != null)
            CachedNetworkImage(
              imageUrl: icon!,
              key: Key('footer_icon'),
              height: 12,
              width: 12,
              fit: BoxFit.cover,
              placeholder: (context, url) => CircularProgressIndicator(),
              errorWidget: (context, url, error) => Icon(Icons.error),
            ),
          SizedBox(width: 5),
          Flexible(
            child: Text(
              text,
              key: Key('footer_text'),
              style: style['text'],
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  Map<String, TextStyle> getStyleSheet(Theme theme) {
    return {
      'text': TextStyle(
        color: changeOpacity(theme.centerChannelColor, 0.5),
        fontSize: 11,
      ),
    };
  }
}
