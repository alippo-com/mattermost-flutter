// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mattermost_flutter/types/theme.dart';
import 'package:mattermost_flutter/utils/theme.dart';

class FormattedText extends StatelessWidget {
  final String id;
  final String defaultMessage;
  final Map<String, dynamic>? values;
  final String? testID;
  final TextStyle? style;
  final TextOverflow ellipsizeMode;
  final int numberOfLines;

  FormattedText({
    required this.id,
    this.defaultMessage = '',
    this.values,
    this.testID,
    this.style,
    this.ellipsizeMode = TextOverflow.clip,
    this.numberOfLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    final intl = Intl.message;
    final Map<String, dynamic> tokenizedValues = {};
    final Map<String, Widget> elements = {};
    String tokenDelimiter = '';

    if (values != null && values!.isNotEmpty) {
      final uid = (DateTime.now().millisecondsSinceEpoch).toString(16);

      String generateToken() {
        return 'ELEMENT-$uid-${tokenizedValues.length + 1}';
      }

      tokenDelimiter = '@__$uid__@';

      values!.forEach((name, value) {
        if (value is Widget) {
          final token = generateToken();
          tokenizedValues[name] = tokenDelimiter + token + tokenDelimiter;
          elements[token] = value;
        } else {
          tokenizedValues[name] = value;
        }
      });
    }

    final formattedMessage = intl(
      defaultMessage,
      name: id,
      args: tokenizedValues.values.toList(),
      desc: '',
      examples: tokenizedValues,
    );

    final hasElements = elements.isNotEmpty;
    List<InlineSpan> nodes;

    if (hasElements) {
      nodes = formattedMessage
          .split(tokenDelimiter)
          .where((part) => part.isNotEmpty)
          .map<InlineSpan>((part) => elements[part] != null
              ? WidgetSpan(child: elements[part]!)
              : TextSpan(text: part))
          .toList();
    } else {
      nodes = [TextSpan(text: formattedMessage)];
    }

    return RichText(
      text: TextSpan(style: style, children: nodes),
      maxLines: numberOfLines,
      overflow: ellipsizeMode,
      key: testID != null ? Key(testID!) : null,
    );
  }
}
