// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mattermost_flutter/components/compass_icon.dart';
import 'package:mattermost_flutter/components/touchable_with_feedback.dart';
import 'package:mattermost_flutter/constants/post_draft.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/utils/file.dart';
import 'package:mattermost_flutter/utils/file/file_picker.dart';
import 'package:mattermost_flutter/utils/theme.dart';

import 'package:mattermost_flutter/types/components/post_draft_quick_action.dart';

class ImageQuickAction extends StatelessWidget {
  final bool disabled;
  final int fileCount;
  final Function(List<String>) onUploadFiles;
  final bool maxFilesReached;
  final int maxFileCount;
  final String testID;

  ImageQuickAction({
    required this.disabled,
    this.fileCount = 0,
    required this.onUploadFiles,
    required this.maxFilesReached,
    required this.maxFileCount,
    this.testID = '',
  });

  void handleButtonPress(BuildContext context) {
    final intl = Intl.of(context);
    final theme = useTheme(context);

    if (maxFilesReached) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(intl.formatMessage(
              id: 'mobile.link.error.title',
              defaultMessage: 'Error',
            )),
            content: Text(fileMaxWarning(intl, maxFileCount)),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      return;
    }

    final picker = PickerUtil(intl, onUploadFiles);
    picker.attachFileFromPhotoGallery(maxFileCount - fileCount);
  }

  @override
  Widget build(BuildContext context) {
    final theme = useTheme(context);
    final actionTestID = disabled ? '$testID.disabled' : testID;
    final color = disabled
        ? changeOpacity(theme.centerChannelColor, 0.16)
        : changeOpacity(theme.centerChannelColor, 0.64);

    return GestureDetector(
      onTap: () => handleButtonPress(context),
      child: Container(
        padding: EdgeInsets.all(10),
        child: CompassIcon(
          color: color,
          name: 'image-outline',
          size: ICON_SIZE,
        ),
      ),
    );
  }
}
