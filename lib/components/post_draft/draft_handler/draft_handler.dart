
// Dart Code
// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:mattermost_flutter/actions/local/draft.dart';
import 'package:mattermost_flutter/context/server.dart';
import 'package:mattermost_flutter/managers/draft_upload_manager.dart';
import 'package:mattermost_flutter/utils/file.dart';
import 'package:mattermost_flutter/components/post_draft/send_handler.dart';

class DraftHandler extends StatefulWidget {
  final String? testID;
  final String channelId;
  final int cursorPosition;
  final String? rootId;
  final bool? canShowPostPriority;
  final List<FileInfo>? files;
  final int maxFileCount;
  final int maxFileSize;
  final bool canUploadFiles;
  final Function(int) updateCursorPosition;
  final Function(double) updatePostInputTop;
  final Function(String) updateValue;
  final String value;
  final Function(bool) setIsFocused;

  DraftHandler({
    this.testID,
    required this.channelId,
    required this.cursorPosition,
    this.rootId,
    this.canShowPostPriority,
    this.files,
    required this.maxFileCount,
    required this.maxFileSize,
    required this.canUploadFiles,
    required this.updateCursorPosition,
    required this.updatePostInputTop,
    required this.updateValue,
    required this.value,
    required this.setIsFocused,
  });

  @override
  _DraftHandlerState createState() => _DraftHandlerState();
}

class _DraftHandlerState extends State<DraftHandler> {
  late String serverUrl;
  late BuildContext context;
  Widget? uploadError;
  Timer? uploadErrorTimeout;
  Map<String, Function?> uploadErrorHandlers = {};

  @override
  void initState() {
    super.initState();
    serverUrl = useServerUrl();
    context = this.context;
  }

  void clearDraft() {
    removeDraft(serverUrl, widget.channelId, widget.rootId!);
    widget.updateValue('');
  }

  void newUploadError(Widget error) {
    if (uploadErrorTimeout != null) {
      uploadErrorTimeout!.cancel();
    }
    setState(() {
      uploadError = error;
    });

    uploadErrorTimeout = Timer(Duration(milliseconds: 5000), () {
      setState(() {
        uploadError = null;
      });
    });
  }

  void addFiles(List<FileInfo> newFiles) {
    if (newFiles.isEmpty) return;

    if (!widget.canUploadFiles) {
      newUploadError(uploadDisabledWarning(context));
      return;
    }

    final currentFileCount = widget.files?.length ?? 0;
    final availableCount = widget.maxFileCount - currentFileCount;
    if (newFiles.length > availableCount) {
      newUploadError(fileMaxWarning(context, widget.maxFileCount));
      return;
    }

    final largeFile =
        newFiles.firstWhere((file) => file.size > widget.maxFileSize, orElse: () => null);
    if (largeFile != null) {
      newUploadError(fileSizeWarning(context, widget.maxFileSize));
      return;
    }

    addFilesToDraft(serverUrl, widget.channelId, widget.rootId!, newFiles);

    newFiles.forEach((file) {
      DraftUploadManager.prepareUpload(serverUrl, file, widget.channelId, widget.rootId!);
      uploadErrorHandlers[file.clientId!] =
          DraftUploadManager.registerErrorHandler(file.clientId!, newUploadError);
    });

    newUploadError(null);
  }

  @override
  Widget build(BuildContext context) {
    return SendHandler(
      testID: widget.testID,
      channelId: widget.channelId,
      rootId: widget.rootId,
      canShowPostPriority: widget.canShowPostPriority,
      cursorPosition: widget.cursorPosition,
      value: widget.value,
      files: widget.files ?? [],
      clearDraft: clearDraft,
      addFiles: addFiles,
      uploadFileError: uploadError,
      updateCursorPosition: widget.updateCursorPosition,
      updatePostInputTop: widget.updatePostInputTop,
      updateValue: widget.updateValue,
      setIsFocused: widget.setIsFocused,
    );
  }
}
