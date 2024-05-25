import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:mattermost_flutter/components/channel_item.dart';
import 'package:mattermost_flutter/constants/view.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/hooks/device.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/typography.dart';

import 'empty_state.dart';

import 'package:mattermost_flutter/typings/database/models/servers/channel.dart';

class UnreadCategories extends StatelessWidget {
  final Function(ChannelModel) onChannelSwitch;
  final bool onlyUnreads;
  final List<ChannelModel> unreadChannels;
  final Map<String, dynamic> unreadThreads;

  UnreadCategories({
    required this.onChannelSwitch,
    required this.onlyUnreads,
    required this.unreadChannels,
    required this.unreadThreads,
  });

  @override
  Widget build(BuildContext context) {
    final intl = Intl.message;
    final theme = useTheme();
    final isTablet = useIsTablet();
    final styles = _getStyleSheet(theme);

    Widget renderItem(BuildContext context, ChannelModel item) {
      return ChannelItem(
        channel: item,
        onPress: onChannelSwitch,
        testID: 'channel_list.category.unreads.channel_item',
        shouldHighlightActive: true,
        shouldHighlightState: true,
        isOnHome: true,
      );
    }

    final showEmptyState = onlyUnreads && unreadChannels.isEmpty;
    final containerStyle = [
      if (showEmptyState && !isTablet) styles['empty'],
    ];

    final showTitle = !onlyUnreads || (onlyUnreads && !showEmptyState);
    final emptyState = showEmptyState && !isTablet
        ? Empty(onlyUnreads: onlyUnreads)
        : null;

    if (unreadChannels.isEmpty &&
        unreadThreads['mentions'] == 0 &&
        unreadThreads['unreads'] == 0 &&
        !onlyUnreads) {
      return Container();
    }

    return Column(
      children: [
        if (showTitle)
          Text(
            intl('mobile.channel_list.unreads', name: 'UNREADS'),
            style: styles['heading'],
          ),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: unreadChannels.length,
            itemBuilder: (context, index) => renderItem(context, unreadChannels[index]),
          ),
        ),
        if (emptyState != null) emptyState,
      ],
    );
  }

  Map<String, dynamic> _getStyleSheet(Theme theme) {
    return {
      'empty': BoxDecoration(
        color: changeOpacity(theme.sidebarText, 0.64),
        alignItems: Alignment.center,
        flexGrow: 1,
        justifyContent: MainAxisAlignment.center,
      ),
      'heading': TextStyle(
        color: changeOpacity(theme.sidebarText, 0.64),
        fontSize: typography('Heading', 75),
        textTransform: TextTransform.uppercase,
        paddingVertical: 8,
        marginTop: 12,
        padding: HOME_PADDING,
      ),
    };
  }
}
