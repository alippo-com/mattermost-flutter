
import 'package:flutter/material.dart';
import 'package:mattermost_flutter/components/markdown.dart';
import 'package:mattermost_flutter/components/formatted_markdown_text.dart';
import 'package:mattermost_flutter/components/formatted_text.dart';
import 'package:mattermost_flutter/utils/markdown.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/types/models/messages.dart';

class LastUsers extends StatefulWidget {
  final String actor;
  final String? channelId;
  final String location;
  final String postType;
  final List<String> usernames;
  final ThemeData theme;

  LastUsers({
    required this.actor,
    this.channelId,
    required this.location,
    required this.postType,
    required this.usernames,
    required this.theme,
  });

  @override
  _LastUsersState createState() => _LastUsersState();
}

class _LastUsersState extends State<LastUsers> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    final style = getStyleSheet(widget.theme);
    final textStyles = getMarkdownTextStyles(widget.theme);

    void onPress() {
      setState(() {
        expanded = true;
      });
    }

    if (expanded) {
      final lastIndex = widget.usernames.length - 1;
      final lastUser = widget.usernames[lastIndex];
      final expandedMessage = postTypeMessages[widget.postType]['many_expanded'];
      final formattedMessage = expandedMessage.replaceAllMapped(RegExp(r'\{(\w+)\}'), (match) {
        switch (match.group(1)) {
          case 'users':
            return widget.usernames.sublist(0, lastIndex).join(', ');
          case 'lastUser':
            return lastUser;
          case 'actor':
            return widget.actor;
          default:
            return match.group(0)!;
        }
      });

      return Markdown(
        baseTextStyle: style['baseText'],
        channelId: widget.channelId,
        location: widget.location,
        textStyles: textStyles,
        value: formattedMessage,
        theme: widget.theme,
      );
    }

    final firstUser = widget.usernames[0];
    final numOthers = widget.usernames.length - 1;

    return Text.rich(
      TextSpan(
        children: [
          WidgetSpan(
            child: FormattedMarkdownText(
              channelId: widget.channelId,
              id: 'last_users_message.first',
              defaultMessage: '{firstUser} and ',
              location: widget.location,
              values: {'firstUser': firstUser},
              baseTextStyle: style['baseText'],
              style: style['baseText'],
            ),
          ),
          TextSpan(text: ' '),
          TextSpan(
            text: '$numOthers others ',
            style: style['linkText'],
            recognizer: TapGestureRecognizer()..onTap = onPress,
          ),
          WidgetSpan(
            child: FormattedMarkdownText(
              channelId: widget.channelId,
              id: systemMessages[widget.postType]['id'],
              defaultMessage: systemMessages[widget.postType]['defaultMessage'],
              location: widget.location,
              values: {'actor': widget.actor},
              baseTextStyle: style['baseText'],
              style: style['baseText'],
            ),
          ),
        ],
      ),
    );
  }

  Map<String, TextStyle> getStyleSheet(ThemeData theme) {
    return {
      'baseText': TextStyle(
        color: theme.textTheme.bodyLarge!.color!.withOpacity(0.6),
        fontSize: 16,
        height: 1.25,
      ),
      'linkText': TextStyle(
        color: theme.primaryColor,
        fontSize: 16,
        height: 1.25,
      ),
    };
  }
}
