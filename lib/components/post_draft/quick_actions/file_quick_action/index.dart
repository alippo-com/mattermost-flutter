import 'package:flutter/material.dart';
import 'package:mattermost_flutter/constants/post_draft.dart';
import 'package:mattermost_flutter/utils/file_picker.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/components/compass_icon.dart';
import 'package:mattermost_flutter/components/touchable_with_feedback.dart';

class FileQuickAction extends StatelessWidget {
  final bool disabled;
  final Function(List<String>) onUploadFiles;
  final bool maxFilesReached;
  final int maxFileCount;
  final String testID;

  FileQuickAction({
    required this.disabled,
    required this.onUploadFiles,
    required this.maxFilesReached,
    required this.maxFileCount,
    this.testID = '',
  });

  void handleButtonPress(BuildContext context, intl) {
    if (maxFilesReached) {
      showAlertDialog(
        context: context,
        title: 'Error',
        message: fileMaxWarning(intl, maxFileCount),
      );
      return;
    }

    final picker = PickerUtil(intl, onUploadFiles);
    picker.attachFileFromFiles();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final actionTestID = disabled ? '$testID.disabled' : testID;
    final color = disabled
        ? changeOpacity(theme.primaryColor, 0.16)
        : changeOpacity(theme.primaryColor, 0.64);

    return TouchableWithFeedback(
      testID: actionTestID,
      disabled: disabled,
      onPress: () => handleButtonPress(context, intl),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: CompassIcon(
          color: color,
          name: 'paperclip',
          size: ICON_SIZE,
        ),
      ),
    );
  }
}

void showAlertDialog({
  required BuildContext context,
  required String title,
  required String message,
}) {
  showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}
