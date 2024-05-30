import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

import 'package:mattermost_flutter/components/error_boundary.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/typography.dart';

class LatexInlineProps {
  final String content;
  final double? maxMathWidth;
  final ThemeData theme;

  LatexInlineProps({
    required this.content,
    this.maxMathWidth,
    required this.theme,
  });
}

class LatexInline extends StatelessWidget {
  final LatexInlineProps props;

  const LatexInline({required this.props});

  @override
  Widget build(BuildContext context) {
    final style = getStyleSheet(props.theme);

    Widget onRenderErrorMessage(String errorMsg) {
      final error = FlutterI18n.translate(context, 'markdown.latex.error');
      return Text(
        '$error: $errorMsg',
        style: style['errorText'],
      );
    }

    return ErrorBoundary(
      error: FlutterI18n.translate(context, 'markdown.latex.error'),
      theme: props.theme,
      child: Container(
        key: Key(props.content),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Math.tex(
            props.content,
            textStyle: style['mathStyle'],
            onErrorFallback: (error) => onRenderErrorMessage(error.message),
          ),
        ),
      ),
    );
  }

  Map<String, TextStyle> getStyleSheet(ThemeData theme) {
    return {
      'mathStyle': TextStyle(
        margin: EdgeInsets.symmetric(vertical: 3),
        color: theme.colorScheme.onSurface,
      ),
      'viewStyle': TextStyle(
        flexDirection: FlexDirection.row,
        flexWrap: FlexWrap.wrap,
      ),
      'errorText': TextStyle(
        color: theme.colorScheme.error,
        flexDirection: FlexDirection.row,
        flexWrap: FlexWrap.wrap,
        fontStyle: FontStyle.italic,
      ).merge(typography('Body', 100)),
    };
  }
}