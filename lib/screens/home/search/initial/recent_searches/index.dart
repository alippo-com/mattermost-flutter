
// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mattermost_flutter/constants.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/typography.dart';
import 'package:mattermost_flutter/widgets/recent_item.dart';
import 'package:provider/provider.dart';

import 'package:mattermost_flutter/types/database/models/servers/team_search_history.dart';

class RecentSearches extends StatelessWidget {
  final void Function(String) setRecentValue;
  final List<TeamSearchHistoryModel> recentSearches;
  final String teamName;

  RecentSearches({
    required this.setRecentValue,
    required this.recentSearches,
    required this.teamName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeNotifier>(context).getTheme();
    final styles = _getStyleFromTheme(theme);

    final title = Intl.message(
      'Recent searches in $teamName',
      name: 'recentSearchesTitle',
      args: [teamName],
    );

    return ListView.builder(
      itemCount: recentSearches.length,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Column(
            children: [
              Divider(
                color: changeOpacity(theme.centerChannelColor, 0.08),
                height: 1,
                thickness: 1,
                indent: 20,
                endIndent: 20,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Text(
                  title,
                  style: typography(context).heading,
                  maxLines: 2,
                ),
              ),
              RecentItem(
                item: recentSearches[index],
                setRecentValue: setRecentValue,
              ),
            ],
          );
        }
        return RecentItem(
          item: recentSearches[index],
          setRecentValue: setRecentValue,
        );
      },
    );
  }

  Map<String, TextStyle> _getStyleFromTheme(ThemeData theme) {
    return {
      'divider': TextStyle(
        color: changeOpacity(theme.centerChannelColor, 0.08),
      ),
      'title': TextStyle(
        color: theme.centerChannelColor,
        fontWeight: FontWeight.w600,
        fontSize: 16,
      ),
    };
  }
}
