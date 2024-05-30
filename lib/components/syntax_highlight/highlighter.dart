// Dart Code
// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:flutter_syntax_view/flutter_syntax_view.dart';
import 'package:mattermost_flutter/types/syntax_highlight_props.dart';
import 'package:mattermost_flutter/context/theme.dart';

const Map<String, SyntaxTheme> codeTheme = {
  'github': SyntaxTheme.githubGist(),
  'monokai': SyntaxTheme.monokai(),
  'solarized-dark': SyntaxTheme.solarized_dark(),
  'solarized-light': SyntaxTheme.solarized_light(),
};

class Highlighter extends StatelessWidget {
  final String code;
  final String language;
  final TextStyle textStyle;
  final bool selectable;

  const Highlighter({
    Key? key,
    required this.code,
    required this.language,
    required this.textStyle,
    this.selectable = false,
  }) : super(key: key);

  int getMaximumLineLength(String code) {
    return code.split('\n').reduce((prev, v) => max(prev, v.length));
  }

  @override
  Widget build(BuildContext context) {
    final theme = useTheme(context);
    final style = codeTheme[theme.codeTheme] ?? SyntaxTheme.githubGist();
    final preTagStyle = [
      selectable ? BoxDecoration(color: style.backgroundColor, flex: 1) : BoxDecoration(color: style.backgroundColor),
      Padding(padding: EdgeInsets.all(5)),
    ];
    final maximumLineLength = getMaximumLineLength(code);
    final languageToUse = maximumLineLength > 300 ? 'text' : language;

    return SyntaxView(
      code: code,
      syntax: Syntax.DART,
      syntaxTheme: style,
      withLinesCount: true,
      expanded: true,
      softWrap: true,
      useCustomHeight: true,
      customHeight: 300,
    );
  }
}
