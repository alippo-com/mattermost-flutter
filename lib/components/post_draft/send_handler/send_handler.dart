
// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:mattermost_flutter/constants/general.dart';
import 'package:mattermost_flutter/constants/calls.dart';
import 'package:mattermost_flutter/database/manager.dart';
import 'package:mattermost_flutter/queries/servers/channel.dart';
import 'package:mattermost_flutter/utils/errors.dart';
import 'package:mattermost_flutter/utils/log.dart';
import 'package:mattermost_flutter/products/calls/connection/connection.dart';
import 'package:mattermost_flutter/products/calls/alerts.dart';
import 'package:mattermost_flutter/products/calls/state.dart';
import 'package:mattermost_flutter/widgets/common_post_options.dart';
import 'package:mattermost_flutter/widgets/formatted_text.dart';
import 'package:mattermost_flutter/widgets/option_item.dart';
import 'package:mattermost_flutter/screens/bottom_sheet.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/typography.dart';

import 'content.dart';
import 'options/mark_as_unread_option.dart';
import 'options/open_in_channel_option.dart';

import 'package:mattermost_flutter/types/database/models/servers/custom_emoji.dart';

class SendHandler extends StatefulWidget {
  final String? testID;
  final String channelId;
  final String? channelType;
  final String? channelName;
  final String currentUserId;
  final int cursorPosition;
  final int maxMessageLength;
  final int membersCount;
  final bool useChannelMentions;
  final bool userIsOutOfOffice;
  final List<CustomEmojiModel> customEmojis;
  final String value;
  final List<FileInfo> files;
  final Function clearDraft;
  final Function(String) updateValue;
  final Function(int) updateCursorPosition;
  final Function(int) updatePostInputTop;
  final Function(List<FileInfo>) addFiles;
  final Widget uploadFileError;
  final int persistentNotificationInterval;
  final int persistentNotificationMaxRecipients;
  final PostPriority postPriority;

  SendHandler({
    this.testID,
    required this.channelId,
    this.channelType,
    this.channelName,
    required this.currentUserId,
    required this.cursorPosition,
    required this.maxMessageLength,
    required this.membersCount,
    required this.useChannelMentions,
    required this.userIsOutOfOffice,
    required this.customEmojis,
    required this.value,
    required this.files,
    required this.clearDraft,
    required this.updateValue,
    required this.updateCursorPosition,
    required this.updatePostInputTop,
    required this.addFiles,
    required this.uploadFileError,
    required this.persistentNotificationInterval,
    required this.persistentNotificationMaxRecipients,
    required this.postPriority,
  });

  @override
  _SendHandlerState createState() => _SendHandlerState();
}

class _SendHandlerState extends State<SendHandler> {
  int channelTimezoneCount = 0;
  bool sendingMessage = false;

  @override
  void initState() {
    super.initState();
    getChannelTimezones(widget.channelId).then((channelTimezones) {
      setState(() {
        channelTimezoneCount = channelTimezones?.length ?? 0;
      });
    });
  }

  bool canSend() {
    if (sendingMessage) {
      return false;
    }

    final messageLength = widget.value.trim().length;

    if (messageLength > widget.maxMessageLength) {
      return false;
    }

    if (widget.files.isNotEmpty) {
      final loadingComplete = widget.files.every((file) => !DraftUploadManager.isUploading(file.clientId!));
      return loadingComplete;
    }

    return messageLength > 0;
  }

  void handleReaction(String emoji, bool add) {
    handleReactionToLatestPost(widget.channelId, emoji, add, widget.rootId);
    widget.clearDraft();
    setState(() {
      sendingMessage = false;
    });
  }

  void handlePostPriority(PostPriority priority) {
    updateDraftPriority(widget.channelId, widget.rootId, priority);
  }

  void doSubmitMessage() {
    final postFiles = widget.files.where((file) => !file.failed).toList();
    final post = Post(
      user_id: widget.currentUserId,
      channel_id: widget.channelId,
      root_id: widget.rootId,
      message: widget.value,
    );

    if (widget.postPriority.priority != null ||
        widget.postPriority.requested_ack != null ||
        widget.postPriority.persistent_notifications != null) {
      post.metadata = PostMetadata(priority: widget.postPriority);
    }

    createPost(widget.channelId, post, postFiles);

    widget.clearDraft();
    setState(() {
      sendingMessage = false;
    });
    // Emit event for post list scroll to bottom
  }

  // Rest of the methods...

  @override
  Widget build(BuildContext context) {
    return DraftInput(
      testID: widget.testID,
      channelId: widget.channelId,
      channelType: widget.channelType,
      channelName: widget.channelName,
      currentUserId: widget.currentUserId,
      rootId: widget.rootId,
      canShowPostPriority: widget.canShowPostPriority,
      cursorPosition: widget.cursorPosition,
      updateCursorPosition: widget.updateCursorPosition,
      value: widget.value,
      files: widget.files,
      updateValue: widget.updateValue,
      addFiles: widget.addFiles,
      uploadFileError: widget.uploadFileError,
      sendMessage: handleSendMessage,
      canSend: canSend(),
      maxMessageLength: widget.maxMessageLength,
      updatePostInputTop: widget.updatePostInputTop,
      postPriority: widget.postPriority,
      updatePostPriority: handlePostPriority,
      persistentNotificationInterval: widget.persistentNotificationInterval,
      persistentNotificationMaxRecipients: widget.persistentNotificationMaxRecipients,
      setIsFocused: widget.setIsFocused,
    );
  }
}
