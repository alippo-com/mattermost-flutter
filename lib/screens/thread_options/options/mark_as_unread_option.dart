import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mattermost_flutter/components/common_post_options/base_option.dart';
import 'package:mattermost_flutter/context/server.dart';
import 'package:mattermost_flutter/i18n.dart';
import 'package:mattermost_flutter/types/screens/navigation.dart';
import 'package:mattermost_flutter/types/database/models/servers/thread.dart';

class MarkAsUnreadOption extends StatelessWidget {
  final AvailableScreens bottomSheetId;
  final String teamId;
  final ThreadModel thread;

  MarkAsUnreadOption({
    required this.bottomSheetId,
    required this.teamId,
    required this.thread,
  });

  @override
  Widget build(BuildContext context) {
    final serverUrl = Provider.of<ServerUrl>(context);

    Future<void> onHandlePress() async {
      await dismissBottomSheet(bottomSheetId);
      if (thread.unreadReplies) {
        markThreadAsRead(serverUrl, teamId, thread.id);
      } else {
        markThreadAsUnread(serverUrl, teamId, thread.id, thread.id);
      }
    }

    final id = thread.unreadReplies ? t('global_threads.options.mark_as_read') : t('mobile.post_info.mark_unread');
    final defaultMessage = thread.unreadReplies ? 'Mark as Read' : 'Mark as Unread';
    final markAsUnreadTestId = thread.unreadReplies ? 'thread_options.mark_as_read.option' : 'thread_options.mark_as_unread.option';

    return BaseOption(
      i18nId: id,
      defaultMessage: defaultMessage,
      iconName: 'mark-as-unread',
      onPress: onHandlePress,
      testID: markAsUnreadTestId,
    );
  }
}
