// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:mattermost_flutter/components/loading.dart';
import 'package:mattermost_flutter/components/team_list_item.dart';
import 'package:mattermost_flutter/types/team_model.dart';

class TeamList extends StatelessWidget {
  final String? iconBackgroundColor;
  final String? iconTextColor;
  final bool loading;
  final VoidCallback? onEndReached;
  final Function(String id) onPress;
  final String? selectedTeamId;
  final List<TeamModel> teams;
  final String? testID;
  final String? textColor;
  final String type;

  TeamList({
    this.iconBackgroundColor,
    this.iconTextColor,
    this.loading = false,
    this.onEndReached,
    required this.onPress,
    this.selectedTeamId,
    required this.teams,
    this.testID,
    this.textColor,
    this.type = 'FlatList',
  });

  @override
  Widget build(BuildContext context) {
    final ListWidget = type == 'FlatList' ? _buildFlatList() : _buildBottomSheetList();

    return Container(
      child: Column(
        children: [
          Expanded(child: ListWidget),
          if (loading) Loading(),
        ],
      ),
    );
  }

  Widget _buildFlatList() {
    return ListView.builder(
      itemCount: teams.length,
      itemBuilder: (context, index) {
        final team = teams[index];
        return TeamListItem(
          onPress: onPress,
          team: team,
          textColor: textColor,
          iconBackgroundColor: iconBackgroundColor,
          iconTextColor: iconTextColor,
          selectedTeamId: selectedTeamId,
        );
      },
    );
  }

  Widget _buildBottomSheetList() {
    // Assuming there's a BottomSheetList equivalent in Flutter
    // Placeholder for BottomSheetList implementation
    return _buildFlatList(); // Placeholder, replace with actual BottomSheetList implementation
  }
}
