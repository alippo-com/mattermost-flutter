// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;

const CUSTOM_STATUS_TIME_PICKER_INTERVALS_IN_MINUTES = 15;
const STATUS_BAR_HEIGHT = 20.0;

void errorBadChannel(BuildContext context, String message) {
  alertErrorWithFallback(context, message);
}

void errorUnknownUser(BuildContext context, String message) {
  alertErrorWithFallback(context, message);
}

void permalinkBadTeam(BuildContext context, String message) {
  alertErrorWithFallback(context, message);
}

void alertErrorWithFallback(BuildContext context, String error, [String fallback, List<Widget> buttons]) {
  String msg = error ?? fallback;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(''),
        content: Text(msg),
        actions: buttons ?? [FlatButton(child: Text('OK'), onPressed: () => Navigator.of(context).pop())],
      );
    },
  );
}

void alertAttachmentFail(BuildContext context, VoidCallback accept, VoidCallback cancel) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Attachment failure'),
        content: Text('Some attachments failed to upload to the server. Are you sure you want to post the message?'),
        actions: [
          FlatButton(child: Text('No'), onPressed: cancel),
          FlatButton(child: Text('Yes'), onPressed: accept),
        ],
      );
    },
  );
}

bool textContainsAtAllAtChannel(String text) {
  final RegExp regex = RegExp(r'(?:(?:^|\s)@|@)(channel|all)(?=\s|$)', caseSensitive: false);
  return regex.hasMatch(text);
}

bool textContainsAtHere(String text) {
  final RegExp regex = RegExp(r'(?:(?:^|\s)@|@)(here)(?=\s|$)', caseSensitive: false);
  return regex.hasMatch(text);
}

String buildChannelWideMentionMessage(BuildContext context, int membersCount, int channelTimezoneCount, bool atHere) {
  String notifyAllMessage = '';

  if (channelTimezoneCount > 0) {
    notifyAllMessage = 'By using @\${atHere ? 'here' : 'all or channel'} you are about to send notifications to \${membersCount - 1} people in \$channelTimezoneCount timezone(s). Are you sure you want to do this?';
  } else {
    notifyAllMessage = 'By using @\${atHere ? 'here' : 'all or channel'} you are about to send notifications to \${membersCount - 1} people. Are you sure you want to do this?';
  }

  return notifyAllMessage;
}

void alertChannelWideMention(BuildContext context, String notifyAllMessage, VoidCallback accept, VoidCallback cancel) {
  alertMessage(context, 'Confirm sending notifications to entire channel', notifyAllMessage, accept, cancel);
}

void alertSendToGroups(BuildContext context, String notifyAllMessage, VoidCallback accept, VoidCallback cancel) {
  alertMessage(context, 'Confirm sending notifications to groups', notifyAllMessage, accept, cancel);
}

void alertMessage(BuildContext context, String message, String notifyAllMessage, VoidCallback accept, VoidCallback cancel) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(message),
        content: Text(notifyAllMessage),
        actions: [
          FlatButton(child: Text('Cancel'), onPressed: cancel),
          FlatButton(child: Text('Confirm'), onPressed: accept),
        ],
      );
    },
  );
}

String getStatusFromSlashCommand(String message) {
  List<String> tokens = message.split(' ');
  String command = tokens[0].substring(1);
  return General.STATUS_COMMANDS.contains(command) ? command : '';
}

void alertSlashCommandFailed(BuildContext context, String error) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Error Executing Command'),
        content: Text(error),
        actions: [
          FlatButton(child: Text('OK'), onPressed: () => Navigator.of(context).pop()),
        ],
      );
    },
  );
}