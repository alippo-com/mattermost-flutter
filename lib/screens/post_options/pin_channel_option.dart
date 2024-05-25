import 'package:flutter/material.dart';
import 'package:mattermost_flutter/actions/remote/post.dart';
import 'package:mattermost_flutter/components/common_post_options.dart';
import 'package:mattermost_flutter/context/server.dart';
import 'package:mattermost_flutter/i18n.dart';
import 'package:mattermost_flutter/screens/navigation.dart';
import 'package:mattermost_flutter/types/screens/navigation.dart';

class PinChannelOption extends StatelessWidget {
  final AvailableScreens bottomSheetId;
  final bool isPostPinned;
  final String postId;

  PinChannelOption({
    required this.bottomSheetId,
    required this.isPostPinned,
    required this.postId,
  });

  @override
  Widget build(BuildContext context) {
    final serverUrl = useServerUrl();

    Future<void> onPress() async {
      await dismissBottomSheet(bottomSheetId);
      togglePinPost(serverUrl, postId);
    }

    String defaultMessage;
    String id;
    String key;

    if (isPostPinned) {
      defaultMessage = 'Unpin from Channel';
      id = t('mobile.post_info.unpin');
      key = 'unpin';
    } else {
      defaultMessage = 'Pin to Channel';
      id = t('mobile.post_info.pin');
      key = 'pin';
    }

    return BaseOption(
      i18nId: id,
      defaultMessage: defaultMessage,
      iconName: 'pin-outline',
      onPress: onPress,
      testID: 'post_options.${key}_post.option',
    );
  }
}
