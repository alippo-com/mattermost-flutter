import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';
import 'package:safe_area/safe_area.dart';
import 'package:mattermost_flutter/components/badge.dart';
import 'package:mattermost_flutter/components/compass_icon.dart';
import 'package:mattermost_flutter/components/files/file_filter.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/hooks/device.dart';
import 'package:mattermost_flutter/screens/bottom_sheet/content.dart';
import 'package:mattermost_flutter/screens/home/search/team_picker_icon.dart';
import 'package:mattermost_flutter/screens/navigation.dart';
import 'package:mattermost_flutter/utils/file.dart';
import 'package:mattermost_flutter/utils/helpers.dart';
import 'package:mattermost_flutter/utils/search.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import './header_button.dart';
import 'package:mattermost_flutter/types/database/models/servers/team.dart';

class Header extends HookWidget {
  final String teamId;
  final Function(String) setTeamId;
  final Function(TabType) onTabSelect;
  final Function(FileFilter) onFilterChanged;
  final TabType selectedTab;
  final FileFilter selectedFilter;
  final List<TeamModel> teams;

  Header({
    required this.teamId,
    required this.setTeamId,
    required this.onTabSelect,
    required this.onFilterChanged,
    required this.selectedTab,
    required this.selectedFilter,
    required this.teams,
  });

  @override
  Widget build(BuildContext context) {
    final theme = useTheme(context);
    final intl = useIntl(context);
    final bottom = useSafeAreaInsets(context).bottom;
    final isTablet = useIsTablet(context);

    final messagesText = intl.formatMessage('screen.search.header.messages', 'Messages');
    final filesText = intl.formatMessage('screen.search.header.files', 'Files');
    final title = intl.formatMessage('screen.search.results.filter.title', 'Filter by file type');

    final showFilterIcon = selectedTab == TabTypes.FILES;
    final hasFilters = selectedFilter != FileFilters.ALL;

    void handleMessagesPress() {
      onTabSelect(TabTypes.MESSAGES);
    }

    void handleFilesPress() {
      onTabSelect(TabTypes.FILES);
    }

    List<double> snapPoints() {
      return [
        1,
        bottomSheetSnapPoint(
          NUMBER_FILTER_ITEMS,
          FILTER_ITEM_HEIGHT,
          bottom,
        ) + TITLE_HEIGHT + DIVIDERS_HEIGHT + (isTablet ? TITLE_SEPARATOR_MARGIN_TABLET : TITLE_SEPARATOR_MARGIN),
      ];
    }

    void handleFilterPress() {
      bottomSheet(
        closeButtonId: 'close-search-filters',
        renderContent: () => Filter(
          initialFilter: selectedFilter,
          setFilter: onFilterChanged,
          title: title,
        ),
        snapPoints: snapPoints(),
        theme: theme,
        title: title,
      );
    }

    final filterStyle = teams.length > 1 ? null : EdgeInsets.only(right: 8);

    return Container(
      decoration: containerDecoration(theme),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
        child: Row(
          children: [
            SelectButton(
              selected: selectedTab == TabTypes.MESSAGES,
              onPress: handleMessagesPress,
              text: messagesText,
            ),
            SelectButton(
              selected: selectedTab == TabTypes.FILES,
              onPress: handleFilesPress,
              text: filesText,
            ),
            Spacer(),
            if (showFilterIcon)
              Padding(
                padding: filterStyle,
                child: CompassIcon(
                  name: 'filter-variant',
                  size: 24,
                  color: changeOpacity(theme.centerChannelColor, 0.56),
                  onPressed: handleFilterPress,
                ),
              ),
            if (showFilterIcon)
              Badge(
                style: badgeDecoration(theme),
                visible: hasFilters,
                value: -1,
              ),
            if (teams.length > 1)
              TeamPickerIcon(
                size: 32,
                divider: true,
                setTeamId: setTeamId,
                teamId: teamId,
                teams: teams,
              ),
          ],
        ),
      ),
    );
  }
}
