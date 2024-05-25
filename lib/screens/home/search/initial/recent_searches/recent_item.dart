import 'package:flutter/material.dart';
import 'package:mattermost_flutter/components/option_item.dart';
import 'package:mattermost_flutter/hooks/server.dart';
import 'package:mattermost_flutter/actions/team.dart';
import 'package:mattermost_flutter/types/database/models/servers/team_search_history.dart';

class RecentItem extends StatelessWidget {
  final Function(String) setRecentValue;
  final TeamSearchHistoryModel item;

  RecentItem({required this.setRecentValue, required this.item});

  @override
  Widget build(BuildContext context) {
    final serverUrl = useServerUrl(context);

    void handlePress() {
      setRecentValue(item.term);
    }

    Future<void> handleRemove() async {
      await removeSearchFromTeamSearchHistory(serverUrl, item.id);
    }

    return OptionItem(
      action: handlePress,
      icon: 'clock-outline',
      inline: true,
      label: item.term,
      onRemove: handleRemove,
      testID: 'search.recent_item.${item.term}',
      type: 'remove',
      containerStyle: const EdgeInsets.only(left: 20),
    );
  }
}
