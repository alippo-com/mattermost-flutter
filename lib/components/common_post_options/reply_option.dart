import 'package:flutter/material.dart';
import 'package:mattermost_flutter/components/common_post_options.dart';
import 'package:mattermost_flutter/context/server.dart';
import 'package:mattermost_flutter/i18n.dart';
import 'package:mattermost_flutter/types/database/models/servers/post.dart';
import 'package:mattermost_flutter/types/screens/navigation.dart';

class ReplyOption extends StatelessWidget {
  final PostModel post;
  final AvailableScreens bottomSheetId;

  ReplyOption({required this.post, required this.bottomSheetId});

  Future<void> handleReply(BuildContext context) async {
    final serverUrl = useServerUrl(context);
    final rootId = post.rootId ?? post.id;
    await dismissBottomSheet(context, bottomSheetId);
    fetchAndSwitchToThread(serverUrl, rootId);
  }

  @override
  Widget build(BuildContext context) {
    return BaseOption(
      i18nId: t('mobile.post_info.reply'),
      defaultMessage: 'Reply',
      iconName: 'reply-outline',
      onPress: () => handleReply(context),
      testID: 'post_options.reply_post.option',
    );
  }
}
