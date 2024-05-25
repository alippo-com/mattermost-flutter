
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mattermost_flutter/components/markdown.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/utils/markdown.dart';
import 'package:mattermost_flutter/utils/theme.dart';

class DialogIntroductionText extends StatelessWidget {
  final String value;

  DialogIntroductionText({required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeNotifier>(context).getTheme();
    final style = _getStyleFromTheme(theme);
    final blockStyles = getMarkdownBlockStyles(theme);
    final textStyles = getMarkdownTextStyles(theme);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15),
      child: Markdown(
        baseTextStyle: style['introductionText']!,
        disableGallery: true,
        textStyles: textStyles,
        blockStyles: blockStyles,
        value: value,
        disableHashtags: true,
        disableAtMentions: true,
        disableChannelLink: true,
        location: '',
        theme: theme,
      ),
    );
  }

  Map<String, TextStyle> _getStyleFromTheme(ThemeData theme) {
    return {
      'introductionText': TextStyle(
        color: theme.centerChannelColor,
      ),
    };
  }
}
