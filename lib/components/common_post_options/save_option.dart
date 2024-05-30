import 'package:flutter/material.dart';
import 'package:mattermost_flutter/actions/preference.dart';
import 'package:mattermost_flutter/components/common_post_options/base_option.dart';
import 'package:mattermost_flutter/context/server.dart';
import 'package:mattermost_flutter/i18n.dart';
import 'package:mattermost_flutter/types.dart';

class SaveOption extends StatelessWidget {
  final AvailableScreens bottomSheetId;
  final bool isSaved;
  final String postId;

  SaveOption({
    required this.bottomSheetId,
    required this.isSaved,
    required this.postId,
  });

  @override
  Widget build(BuildContext context) {
    final serverUrl = useServerUrl(context);

    Future<void> onHandlePress() async {
      final remoteAction = isSaved ? deleteSavedPost : savePostPreference;
      await dismissBottomSheet(bottomSheetId);
      remoteAction(serverUrl, postId);
    }

    final id = isSaved ? t('mobile.post_info.unsave') : t('mobile.post_info.save');
    final defaultMessage = isSaved ? 'Unsave' : 'Save';

    return BaseOption(
      i18nId: id,
      defaultMessage: defaultMessage,
      iconName: 'bookmark-outline',
      onPress: onHandlePress,
      testID: 'post_options.${defaultMessage.toLowerCase()}_post.option',
    );
  }
}
