// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:mattermost_flutter/utils/general.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/types.dart';

class CodeHighlightRenderer extends StatelessWidget {
  final String defaultColor;
  final int digits;
  final String fontFamily;
  final double? fontSize;
  final List<dynamic> rows;
  final bool selectable;
  final dynamic stylesheet;

  CodeHighlightRenderer({
    required this.defaultColor,
    required this.digits,
    required this.fontFamily,
    this.fontSize,
    required this.rows,
    required this.selectable,
    required this.stylesheet,
  });

  @override
  Widget build(BuildContext context) {
    final listKey = generateId();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: rows.length,
        itemBuilder: (context, index) {
          final item = rows[index];
          return createNativeElement(
            node: item,
            stylesheet: stylesheet,
            key: 'code-segment-\$index',
            defaultColor: defaultColor,
            fontFamily: fontFamily,
            fontSize: fontSize,
            selectable: selectable,
            digits: digits,
          );
        },
      ),
    );
  }

  Widget createNativeElement({
    required dynamic node,
    required dynamic stylesheet,
    required String key,
    required String defaultColor,
    required String fontFamily,
    double? fontSize = 12.0,
    required bool selectable,
    required int digits,
  }) {
    final properties = node['properties'];
    final type = node['type'];
    final tagName = node['tagName'];
    final value = node['value'];
    final startingStyle = TextStyle(fontFamily: fontFamily, fontSize: fontSize, height: fontSize! + 7);

    if (properties != null && properties['key'] != null && properties['key'].startsWith('line-number')) {
      var valueString = '\${node['children'][0]['value']}. ';
      while (valueString.length < digits + 2) {
        valueString += ' ';
      }

      return Text(
        valueString,
        key: Key(key),
        style: startingStyle.copyWith(color: changeOpacity(defaultColor, 0.75), paddingRight: 5),
      );
    }

    if (type == 'text') {
      return Text(
        value,
        key: Key(key),
        style: startingStyle.copyWith(color: defaultColor),
        selectionColor: selectable ? defaultColor : null,
      );
    } else if (tagName != null) {
      final childrenCreator = createChildren(
        stylesheet: stylesheet,
        fontSize: fontSize,
        fontFamily: fontFamily,
        digits: digits,
      );

      if (properties != null && properties['style'] != null) {
        if (properties['style']['display'] != null) {
          properties['style']['display'] = 'flex';
        }
        if (properties['style']['paddingRight'] != null) {
          properties['style']['paddingRight'] = null;
        }
        if (properties['style']['userSelect'] != null) {
          properties['style']['userSelect'] = null;
        }
      }

      final style = createStyleObject(
        properties['className'],
        {
          'color': defaultColor,
          ...?properties['style'],
          ...startingStyle,
        },
        stylesheet,
      );

      final children = childrenCreator(node['children'], style.color ?? defaultColor);
      return Text(
        children.toString(),
        key: Key(key),
        style: style,
        selectionColor: selectable ? defaultColor : null,
      );
    }

    return SizedBox.shrink();
  }

  Function createChildren({
    required dynamic stylesheet,
    double? fontSize = 12.0,
    required String fontFamily,
    required int digits,
  }) {
    var childrenCount = 0;
    return (List<dynamic> children, String defaultColor) {
      childrenCount += 1;
      return children.map((child) {
        return createNativeElement(
          node: child,
          stylesheet: stylesheet,
          key: 'code-segment-\$childrenCount-\${children.indexOf(child)}',
          defaultColor: defaultColor,
          fontFamily: fontFamily,
          fontSize: fontSize,
          selectable: selectable,
          digits: digits,
        );
      }).toList();
    };
  }

  TextStyle createStyleObject(String className, Map<String, dynamic> properties, dynamic stylesheet) {
    // Implementation for creating style object from stylesheet
    // ...
    return TextStyle();
  }
}
