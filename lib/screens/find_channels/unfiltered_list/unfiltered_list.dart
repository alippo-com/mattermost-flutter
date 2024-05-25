// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:reorderables_flutter/reorderables_flutter.dart';
import 'package:mattermost_flutter/components/channel_item.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/i18n.dart';
import 'package:mattermost_flutter/types/channel_model.dart';

import 'header.dart';

class UnfilteredList extends HookWidget {
  final Future<void> Function() close;
  final int keyboardOverlap;
  final List<ChannelModel> recentChannels;
  final bool showTeamName;
  final String? testID;

  UnfilteredList({
    required this.close,
    required this.keyboardOverlap,
    required this.recentChannels,
    required this.showTeamName,
    this.testID,
  });

  @override
  Widget build(BuildContext context) {
    final intl = useIntl();
    final serverUrl = useServerUrl();
    final sections = useState(buildSections(recentChannels));
    final sectionListStyle = useMemoized(() => EdgeInsets.only(bottom: keyboardOverlap), [keyboardOverlap]);

    useEffect(() {
      sections.value = buildSections(recentChannels);
    }, [recentChannels]);

    Future<void> onPress(ChannelModel c) async {
      await close();
      switchToChannelById(serverUrl, c.id);
    }

    Widget renderSectionHeader(ChannelModel section) {
      return FindChannelsHeader(
        sectionName: intl.formatMessage(id: section.id, defaultMessage: section.defaultMessage),
      );
    }

    Widget renderSectionItem(ChannelModel item) {
      return ChannelItem(
        channel: item,
        onPress: () => onPress(item),
        isOnCenterBg: true,
        showTeamName: showTeamName,
        shouldHighlightState: true,
        testID: '$testID.channel_item',
      );
    }

    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      child: ReorderableColumn(
        padding: sectionListStyle,
        children: sections.value.map<Widget>((section) {
          return Column(
            key: ValueKey(section.id),
            children: [
              renderSectionHeader(section),
              ...section.data.map<Widget>((item) => renderSectionItem(item)).toList()
            ],
          );
        }).toList(),
      ),
    );
  }

  List<ChannelModel> buildSections(List<ChannelModel> recentChannels) {
    final sections = <ChannelModel>[];
    if (recentChannels.isNotEmpty) {
      sections.add(ChannelModel(
        id: t('mobile.channel_list.recent'),
        defaultMessage: 'Recent',
        data: recentChannels,
      ));
    }
    return sections;
  }
}
