import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:mattermost_flutter/actions/remote/permalink.dart';
import 'package:mattermost_flutter/components/common_post_options/base_option.dart';
import 'package:mattermost_flutter/context/server.dart';
import 'package:mattermost_flutter/i18n.dart';
import 'package:mattermost_flutter/screens/navigation.dart';
import 'package:mattermost_flutter/types/screens/navigation.dart';

class OpenInChannelOption extends StatelessWidget {
  final String bottomSheetId;
  final String threadId;

  OpenInChannelOption({
    required this.bottomSheetId,
    required this.threadId,
  });

  @override
  Widget build(BuildContext context) {
    final intl = Provider.of<Intl>(context);
    final serverUrl = Provider.of<ServerUrl>(context);

    Future<void> onHandlePress() async {
      await dismissBottomSheet(bottomSheetId);
      showPermalink(serverUrl, '', threadId);
    }

    return BaseOption(
      i18nId: t('global_threads.options.open_in_channel'),
      defaultMessage: 'Open in Channel',
      iconName: 'globe',
      onPress: onHandlePress,
      testID: 'thread_options.open_in_channel.option',
    );
  }
}
