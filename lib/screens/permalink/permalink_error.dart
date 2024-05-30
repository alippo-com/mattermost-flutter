import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mattermost_flutter/components/formatted_text.dart';
import 'package:mattermost_flutter/components/join_private_channel.dart';
import 'package:mattermost_flutter/components/join_public_channel.dart';
import 'package:mattermost_flutter/components/message_not_viewable.dart';
import 'package:mattermost_flutter/components/markdown.dart';
import 'package:mattermost_flutter/utils/markdown.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/typography.dart';

class PermalinkError extends StatelessWidget {
  final PermalinkErrorType error;
  final VoidCallback handleClose;
  final VoidCallback handleJoin;

  PermalinkError({
    required this.error,
    required this.handleClose,
    required this.handleJoin,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = getStyleSheet(theme);
    final intl = Intl.message;

    final buttonStylePrimary = buttonBackgroundStyle(theme, 'lg', 'primary');
    final buttonTextStylePrimary = buttonTextStyle(theme, 'lg', 'primary');

    if (error.notExist || error.unreachable) {
      final title = intl('permalink.error.access.title', name: 'Message not viewable');
      final text = intl('permalink.error.access.text', name: 'The message you are trying to view is in a channel you don’t have access to or has been deleted.');
      return Column(
        children: [
          Container(
            alignment: Alignment.center,
            margin: EdgeInsets.symmetric(horizontal: 36),
            child: Column(
              children: [
                MessageNotViewable(theme: theme),
                Text(title, style: style.errorTitle),
                Text(text, style: style.errorText),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: changeOpacity(theme.centerChannelColor, 0.16),
                  width: 1,
                ),
              ),
            ),
            child: GestureDetector(
              onTap: handleClose,
              child: Container(
                decoration: buttonStylePrimary,
                child: FormattedText(
                  id: 'permalink.error.okay',
                  defaultMessage: 'Okay',
                  style: buttonTextStylePrimary,
                ),
              ),
            ),
          ),
        ],
      );
    }

    final buttonStyleTertiary = buttonBackgroundStyle(theme, 'lg', 'tertiary');
    final buttonTextStyleTertiary = buttonTextStyle(theme, 'lg', 'tertiary');

    final isPrivate = error.privateChannel || error.privateTeam;
    Widget image;
    String title;
    String text;
    String button;

    if (isPrivate && error.joinedTeam) {
      image = JoinPrivateChannel(theme: theme);
      title = intl('permalink.error.private_channel_and_team.title', name: 'Join private channel and team');
      text = intl('permalink.error.private_channel_and_team.text', name: 'The message you are trying to view is in a private channel in a team you are not a member of. You have access as an admin. Do you want to join **{channelName}** and the **{teamName}** team to view it?', args: {'channelName': error.channelName, 'teamName': error.teamName});
      button = intl('permalink.error.private_channel_and_team.button', name: 'Join channel and team');
    } else if (isPrivate) {
      image = JoinPrivateChannel(theme: theme);
      title = intl('permalink.error.private_channel.title', name: 'Join private channel');
      text = intl('permalink.error.private_channel.text', name: 'The message you are trying to view is in a private channel you have not been invited to, but you have access as an admin. Do you still want to join **{channelName}**?', args: {'channelName': error.channelName});
      button = intl('permalink.error.private_channel.button', name: 'Join channel');
    } else if (error.joinedTeam) {
      image = JoinPublicChannel(theme: theme);
      title = intl('permalink.error.public_channel_and_team.title', name: 'Join channel and team');
      text = intl('permalink.error.public_channel_and_team.text', name: 'The message you are trying to view is in a channel you don’t belong and a team you are not a member of. Do you want to join **{channelName}** and the **{teamName}** team to view it?', args: {'channelName': error.channelName, 'teamName': error.teamName});
      button = intl('permalink.error.public_channel_and_team.button', name: 'Join channel and team');
    } else {
      image = JoinPublicChannel(theme: theme);
      title = intl('permalink.error.public_channel.title', name: 'Join channel');
      text = intl('permalink.error.public_channel.text', name: 'The message you are trying to view is in a channel you don’t belong to. Do you want to join **{channelName}** to view it?', args: {'channelName': error.channelName});
      button = intl('permalink.error.public_channel.button', name: 'Join channel');
    }

    return Column(
      children: [
        Container(
          alignment: Alignment.center,
          margin: EdgeInsets.symmetric(horizontal: 36),
          child: Column(
            children: [
              image,
              Text(title, style: style.errorTitle),
              Markdown(
                data: text,
                styleSheet: MarkdownStyleSheet(
                  p: style.errorText,
                  h1: style.errorTextParagraph,
                ),
                selectable: false,
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: changeOpacity(theme.centerChannelColor, 0.16),
                width: 1,
              ),
            ),
          ),
          child: Column(
            children: [
              GestureDetector(
                onTap: handleJoin,
                child: Container(
                  decoration: buttonStylePrimary,
                  child: Text(button, style: buttonTextStylePrimary),
                ),
              ),
              GestureDetector(
                onTap: handleClose,
                child: Container(
                  decoration: buttonStyleTertiary,
                  margin: EdgeInsets.only(top: 8),
                  child: FormattedText(
                    id: 'permalink.error.cancel',
                    defaultMessage: 'Cancel',
                    style: buttonTextStyleTertiary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Map<String, TextStyle> getStyleSheet(ThemeData theme) {
    return {
      'errorTitle': TextStyle(
        color: theme.centerChannelColor,
        textAlign: TextAlign.center,
        fontWeight: FontWeight.w600,
        fontSize: 24,
        margin: EdgeInsets.symmetric(vertical: 16),
      ),
      'errorText': TextStyle(
        color: theme.centerChannelColor,
        textAlign: TextAlign.center,
        fontSize: 16,
      ),
      'errorTextParagraph': TextStyle(
        textAlign: TextAlign.center,
      ),
    };
  }
}

class PermalinkErrorType {
  final bool notExist;
  final bool unreachable;
  final bool privateChannel;
  final bool privateTeam;
  final bool joinedTeam;
  final String channelName;
  final String teamName;

  PermalinkErrorType({
    required this.notExist,
    required this.unreachable,
    required this.privateChannel,
    required this.privateTeam,
    required this.joinedTeam,
    required this.channelName,
    required this.teamName,
  });
}
