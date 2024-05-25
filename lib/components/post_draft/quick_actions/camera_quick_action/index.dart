import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter/services.dart';
import 'package:mattermost_flutter/components/compass_icon.dart';
import 'package:mattermost_flutter/constants.dart';
import 'package:mattermost_flutter/utils/file_picker.dart';
import 'package:mattermost_flutter/utils/helpers.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/components/touchable_with_feedback.dart';
import 'package:mattermost_flutter/screens/navigation.dart';
import 'package:mattermost_flutter/screens/bottom_sheet/content.dart';
import 'package:mattermost_flutter/typings/components/post_draft_quick_action.dart';

import 'camera_type.dart';

class CameraQuickAction extends HookWidget {
  final bool disabled;
  final Function(List<File>) onUploadFiles;
  final bool maxFilesReached;
  final int maxFileCount;
  final String testID;

  CameraQuickAction({
    required this.disabled,
    required this.onUploadFiles,
    required this.maxFilesReached,
    required this.maxFileCount,
    required this.testID,
  });

  @override
  Widget build(BuildContext context) {
    final intl = useIntl();
    final theme = useTheme();
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    final handleButtonPress = useCallback((CameraOptions options) {
      final picker = PickerUtil(intl, onUploadFiles);
      picker.attachFileFromCamera(options);
    }, [intl, onUploadFiles]);

    final renderContent = useCallback(() {
      return CameraType(
        onPress: handleButtonPress,
      );
    }, [handleButtonPress]);

    final openSelectorModal = useCallback(() {
      if (maxFilesReached) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(intl.formatMessage({'id': 'mobile.link.error.title', 'defaultMessage': 'Error'})),
              content: Text(fileMaxWarning(intl, maxFileCount)),
              actions: [
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

      bottomSheet(
        context: context,
        title: intl.formatMessage({'id': 'mobile.camera_type.title', 'defaultMessage': 'Camera options'}),
        renderContent: renderContent,
        snapPoints: [1, bottomSheetSnapPoint(2, ITEM_HEIGHT, bottom) + TITLE_HEIGHT],
        theme: theme,
        closeButtonId: 'camera-close-id',
      );
    }, [intl, theme, renderContent, maxFilesReached, maxFileCount, bottom, context]);

    final actionTestID = disabled ? '$testID.disabled' : testID;
    final color = disabled ? changeOpacity(theme.centerChannelColor, 0.16) : changeOpacity(theme.centerChannelColor, 0.64);

    return TouchableWithFeedback(
      testID: actionTestID,
      disabled: disabled,
      onPress: openSelectorModal,
      style: style.icon,
      type: 'opacity',
      child: CompassIcon(
        color: color,
        name: 'camera-outline',
        size: ICON_SIZE,
      ),
    );
  }
}

final style = {
  'icon': BoxDecoration(
    alignItems: 'center',
    justifyContent: 'center',
    padding: EdgeInsets.all(10),
  ),
};
