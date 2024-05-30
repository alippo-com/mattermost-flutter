
// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:mattermost_flutter/types/database/category_model.dart';
import 'package:mattermost_flutter/types/database/channel_model.dart';
import 'package:mattermost_flutter/actions/remote/channel.dart';
import 'package:mattermost_flutter/components/loading.dart';
import 'package:mattermost_flutter/components/category_body.dart';
import 'package:mattermost_flutter/components/load_categories_error.dart';
import 'package:mattermost_flutter/components/category_header.dart';
import 'package:mattermost_flutter/components/unread_categories.dart';
import 'package:mattermost_flutter/utils/server.dart';
import 'package:mattermost_flutter/hooks/team_switch.dart';

class Categories extends HookWidget {
  final List<CategoryModel> categories;
  final bool onlyUnreads;
  final bool unreadsOnTop;

  Categories({
    required this.categories,
    required this.onlyUnreads,
    required this.unreadsOnTop,
  });

  @override
  Widget build(BuildContext context) {
    final intl = AppLocalizations.of(context)!;
    final listRef = useRef<ScrollController>(ScrollController());
    final serverUrl = useServerUrl();
    final isTablet = useIsTablet();
    final switchingTeam = useTeamSwitch();
    final teamId = categories.isNotEmpty ? categories[0].teamId : null;
    final showOnlyUnreadsCategory = onlyUnreads && !unreadsOnTop;

    final categoriesToShow = useMemo(() {
      if (showOnlyUnreadsCategory) {
        return ['UNREADS'];
      }

      final orderedCategories = List<CategoryModel>.from(categories);
      orderedCategories.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

      if (unreadsOnTop) {
        return ['UNREADS', ...orderedCategories];
      }
      return orderedCategories;
    }, [categories, unreadsOnTop, showOnlyUnreadsCategory]);

    final initialLoad = useState(!categoriesToShow.isNotEmpty);

    final onChannelSwitch = useCallback((Channel channel) async {
      switchToChannelById(serverUrl, channel.id);
    }, [serverUrl]);

    final renderCategory = useCallback((category) {
      if (category == 'UNREADS') {
        return UnreadCategories(
          currentTeamId: teamId,
          isTablet: isTablet,
          onChannelSwitch: onChannelSwitch,
          onlyUnreads: showOnlyUnreadsCategory,
        );
      }
      return Column(
        children: [
          CategoryHeader(category: category),
          CategoryBody(
            category: category,
            isTablet: isTablet,
            locale: intl.locale,
            onChannelSwitch: onChannelSwitch,
          ),
        ],
      );
    }, [teamId, intl.locale, isTablet, onChannelSwitch, showOnlyUnreadsCategory]);

    useEffect(() {
      Future.delayed(Duration.zero, () {
        setInitialLoad(false);
      });
    }, []);

    if (categories.isEmpty) {
      return LoadCategoriesError();
    }

    return Column(
      children: [
        if (!switchingTeam && !initialLoad && showOnlyUnreadsCategory)
          Expanded(
            child: UnreadCategories(
              currentTeamId: teamId,
              isTablet: isTablet,
              onChannelSwitch: onChannelSwitch,
              onlyUnreads: showOnlyUnreadsCategory,
            ),
          ),
        if (!switchingTeam && !initialLoad && !showOnlyUnreadsCategory)
          Expanded(
            child: ListView.builder(
              controller: listRef.value,
              itemCount: categoriesToShow.length,
              itemBuilder: (context, index) {
                final category = categoriesToShow[index];
                return renderCategory(category);
              },
            ),
          ),
        if (switchingTeam || initialLoad)
          Expanded(
            child: Center(
              child: Loading(
                size: 'large',
                themeColor: 'sidebarText',
              ),
            ),
          ),
      ],
    );
  }
}
