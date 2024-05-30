
import 'package:flutter/material.dart';
import 'package:mattermost_flutter/components/common_post_options/base_option.dart';
import 'package:mattermost_flutter/context/server.dart';
import 'package:mattermost_flutter/i18n.dart';
import 'package:mattermost_flutter/types/database/models/servers/post.dart';
import 'package:mattermost_flutter/types/screens/navigation.dart';
import 'package:mattermost_flutter/actions/remote/post.dart';

class MarkAsUnreadOption extends StatefulWidget {
  final AvailableScreens bottomSheetId;
  final bool isCRTEnabled;
  final AvailableScreens sourceScreen;
  final PostModel post;
  final String teamId;

  const MarkAsUnreadOption({
    required this.bottomSheetId,
    required this.isCRTEnabled,
    required this.sourceScreen,
    required this.post,
    required this.teamId,
  });

  @override
  _MarkAsUnreadOptionState createState() => _MarkAsUnreadOptionState();
}

class _MarkAsUnreadOptionState extends State<MarkAsUnreadOption> {
  late String serverUrl;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    serverUrl = useServerUrl();
  }

  void onPress() async {
    await dismissBottomSheet(widget.bottomSheetId);
    if (widget.sourceScreen == Screens.THREAD && widget.isCRTEnabled) {
      final threadId = widget.post.rootId ?? widget.post.id;
      markThreadAsUnread(serverUrl, widget.teamId, threadId, widget.post.id);
    } else {
      markPostAsUnread(serverUrl, widget.post.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseOption(
      i18nId: t('mobile.post_info.mark_unread'),
      defaultMessage: 'Mark as Unread',
      iconName: 'mark-as-unread',
      onPress: onPress,
      testID: 'post_options.mark_as_unread.option',
    );
  }
}
