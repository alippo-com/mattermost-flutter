// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/types/theme.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AttachmentAuthor extends StatelessWidget {
  final String? icon;
  final String? link;
  final String? name;
  final Theme theme;

  AttachmentAuthor({
    required this.icon,
    required this.link,
    required this.name,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final style = getStyleSheet(theme);

    void openLink() {
      if (link != null) {
        try {
          launch(link!);
        } catch (e) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Error'),
                content: Text('Unable to open the link.'),
                actions: <Widget>[
                  TextButton(
                    child: Text('OK'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        }
      }
    }

    return Row(
      children: [
        if (icon != null)
          CachedNetworkImage(
            imageUrl: icon!,
            key: Key('author_icon'),
            width: 12,
            height: 12,
          ),
        if (name != null)
          GestureDetector(
            onTap: openLink,
            child: Text(
              name!,
              key: Key('author_name'),
              style: TextStyle(
                color: link != null ? theme.linkColor : theme.centerChannelColor.withOpacity(0.5),
                fontSize: 11,
              ),
            ),
          ),
      ],
    );
  }

  Map<String, TextStyle> getStyleSheet(Theme theme) {
    return {
      'container': TextStyle(
        flex: 1,
        flexDirection: 'row',
      ),
      'icon': TextStyle(
        height: 12,
        marginRight: 3,
        width: 12,
      ),
      'name': TextStyle(
        color: theme.centerChannelColor.withOpacity(0.5),
        fontSize: 11,
      ),
      'link': TextStyle(
        color: theme.linkColor.withOpacity(0.5),
      ),
    };
  }
}
