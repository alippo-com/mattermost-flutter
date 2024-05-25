
// Dart Code
// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:mattermost_flutter/components/quick_actions/camera_quick_action.dart';
import 'package:mattermost_flutter/components/quick_actions/file_quick_action.dart';
import 'package:mattermost_flutter/components/quick_actions/image_quick_action.dart';
import 'package:mattermost_flutter/components/quick_actions/input_quick_action.dart';
import 'package:mattermost_flutter/components/quick_actions/post_priority_action.dart';
import 'package:mattermost_flutter/types/file_info.dart';
import 'package:mattermost_flutter/types/post_priority.dart';

class QuickActions extends StatelessWidget {
  final String? testID;
  final bool canUploadFiles;
  final int fileCount;
  final bool isPostPriorityEnabled;
  final bool? canShowPostPriority;
  final int maxFileCount;
  final String value;
  final Function(String) updateValue;
  final Function(List<FileInfo>) addFiles;
  final PostPriority postPriority;
  final Function(PostPriority) updatePostPriority;
  final Function focus;

  QuickActions({
    this.testID,
    required this.canUploadFiles,
    required this.fileCount,
    required this.isPostPriorityEnabled,
    this.canShowPostPriority,
    required this.maxFileCount,
    required this.value,
    required this.updateValue,
    required this.addFiles,
    required this.postPriority,
    required this.updatePostPriority,
    required this.focus,
  });

  @override
  Widget build(BuildContext context) {
    final atDisabled = value.isNotEmpty && value[value.length - 1] == '@';
    final slashDisabled = value.isNotEmpty;

    final atInputActionTestID = '${testID ?? ''}.at_input_action';
    final slashInputActionTestID = '${testID ?? ''}.slash_input_action';
    final fileActionTestID = '${testID ?? ''}.file_action';
    final imageActionTestID = '${testID ?? ''}.image_action';
    final cameraActionTestID = '${testID ?? ''}.camera_action';
    final postPriorityActionTestID = '${testID ?? ''}.post_priority_action';

    final uploadProps = {
      'disabled': !canUploadFiles,
      'fileCount': fileCount,
      'maxFileCount': maxFileCount,
      'maxFilesReached': fileCount >= maxFileCount,
      'onUploadFiles': addFiles,
    };

    return Container(
      key: Key(testID ?? ''),
      height: 44,
      child: Row(
        children: [
          InputAction(
            key: Key(atInputActionTestID),
            disabled: atDisabled,
            inputType: 'at',
            updateValue: updateValue,
            focus: focus,
          ),
          InputAction(
            key: Key(slashInputActionTestID),
            disabled: slashDisabled,
            inputType: 'slash',
            updateValue: updateValue,
            focus: focus,
          ),
          FileAction(
            key: Key(fileActionTestID),
            uploadProps: uploadProps,
          ),
          ImageAction(
            key: Key(imageActionTestID),
            uploadProps: uploadProps,
          ),
          CameraAction(
            key: Key(cameraActionTestID),
            uploadProps: uploadProps,
          ),
          if (isPostPriorityEnabled && (canShowPostPriority ?? false))
            PostPriorityAction(
              key: Key(postPriorityActionTestID),
              postPriority: postPriority,
              updatePostPriority: updatePostPriority,
            ),
        ],
      ),
    );
  }
}
