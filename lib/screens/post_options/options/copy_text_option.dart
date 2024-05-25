import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mattermost_flutter/components/common_post_options.dart';
import 'package:mattermost_flutter/constants/snack_bar.dart';
import 'package:mattermost_flutter/i18n.dart';
import 'package:mattermost_flutter/screens/navigation.dart';
import 'package:mattermost_flutter/utils/snack_bar.dart';
import 'package:mattermost_flutter/types/screens/navigation.dart';

class CopyTextOption extends StatelessWidget {
  final AvailableScreens bottomSheetId;
  final AvailableScreens sourceScreen;
  final String postMessage;

  CopyTextOption({
    required this.bottomSheetId,
    required this.sourceScreen,
    required this.postMessage,
  });

  Future<void> handleCopyText(BuildContext context) async {
    Clipboard.setData(ClipboardData(text: postMessage));
    await dismissBottomSheet(bottomSheetId);
    if ((Theme.of(context).platform == TargetPlatform.android && Theme.of(context).platformVersion < 33) || Theme.of(context).platform == TargetPlatform.iOS) {
      showSnackBar(context, SNACK_BAR_TYPE.MESSAGE_COPIED, sourceScreen);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseOption(
      i18nId: t('mobile.post_info.copy_text'),
      defaultMessage: 'Copy Text',
      iconName: Icons.content_copy,
      onPress: () => handleCopyText(context),
      testID: 'post_options.copy_text.option',
    );
  }
}
