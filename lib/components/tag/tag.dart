
import 'package:flutter/material.dart';
import 'package:mattermost_flutter/components/formatted_text.dart'; // Custom widget
import 'package:mattermost_flutter/utils/theme.dart'; // Custom utility
import 'package:mattermost_flutter/i18n.dart'; // Custom utility

class Tag extends StatelessWidget {
  final String id;
  final String defaultMessage;
  final bool inTitle;
  final bool show;
  final TextStyle? textStyle;
  final BoxDecoration? style;
  final String? testID;

  Tag({
    required this.id,
    required this.defaultMessage,
    this.inTitle = false,
    this.show = true,
    this.textStyle,
    this.style,
    this.testID,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (!show) {
      return SizedBox.shrink();
    }

    final containerStyle = BoxDecoration(
      color: theme.colorScheme.secondary.withOpacity(0.08),
      borderRadius: BorderRadius.circular(4),
    ).merge(style);

    final textStyle = TextStyle(
      color: theme.colorScheme.onSecondary,
      fontFamily: 'OpenSans-SemiBold',
      fontSize: 10,
      textTransform: TextTransform.uppercase,
    ).merge(this.textStyle);

    final titleStyle = inTitle
        ? TextStyle(
            backgroundColor: theme.colorScheme.primary.withOpacity(0.15),
            color: theme.colorScheme.primary.withOpacity(0.6),
          )
        : null;

    return Container(
      decoration: containerStyle,
      padding: EdgeInsets.symmetric(vertical: 2, horizontal: 4),
      alignment: Alignment.center,
      child: FormattedText(
        id: id,
        defaultMessage: defaultMessage,
        style: textStyle.merge(titleStyle),
        testID: testID,
      ),
    );
  }
}

class BotTag extends StatelessWidget {
  final bool inTitle;
  final bool show;
  final TextStyle? textStyle;
  final BoxDecoration? style;
  final String? testID;

  BotTag({
    this.inTitle = false,
    this.show = true,
    this.textStyle,
    this.style,
    this.testID,
  });

  @override
  Widget build(BuildContext context) {
    return Tag(
      id: t('post_info.bot'),
      defaultMessage: 'Bot',
      inTitle: inTitle,
      show: show,
      textStyle: textStyle,
      style: style,
      testID: testID,
    );
  }
}

class GuestTag extends StatelessWidget {
  final bool inTitle;
  final bool show;
  final TextStyle? textStyle;
  final BoxDecoration? style;
  final String? testID;

  GuestTag({
    this.inTitle = false,
    this.show = true,
    this.textStyle,
    this.style,
    this.testID,
  });

  @override
  Widget build(BuildContext context) {
    return Tag(
      id: t('post_info.guest'),
      defaultMessage: 'Guest',
      inTitle: inTitle,
      show: show,
      textStyle: textStyle,
      style: style,
      testID: testID,
    );
  }
}
