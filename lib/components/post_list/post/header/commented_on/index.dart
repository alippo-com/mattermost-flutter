// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:mattermost_flutter/components/formatted_text.dart';
import 'package:mattermost_flutter/utils/theme.dart';

class HeaderCommentedOn extends StatelessWidget {
  final String locale;
  final String name;
  final ThemeData theme;

  const HeaderCommentedOn({
    Key? key,
    required this.locale,
    required this.name,
    required this.theme,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final style = _getStyleSheet(theme);
    String apostrophe;

    if (locale.toLowerCase().startsWith('en')) {
      if (name.endsWith('s')) {
        apostrophe = ''';
      } else {
        apostrophe = ''s';
      }
    } else {
      apostrophe = '';
    }

    return FormattedText(
      id: 'post_body.commentedOn',
      defaultMessage: 'Commented on {name}{apostrophe} message: ',
      values: {'name': name, 'apostrophe': apostrophe},
      style: style['commentedOn'],
      testID: 'post_header.commented_on',
    );
  }

  Map<String, TextStyle> _getStyleSheet(ThemeData theme) {
    return {
      'commentedOn': TextStyle(
        color: changeOpacity(theme.textTheme.headline1!.color!, 0.65),
        marginBottom: 3,
        lineHeight: 21,
      ),
    };
  }
}

double changeOpacity(Color color, double opacity) {
  return color.withOpacity(opacity);
}
