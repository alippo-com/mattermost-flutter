// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:mattermost_flutter/components/category_header.dart';
import 'package:mattermost_flutter/types/database/models/servers/category.dart';

class EnhancedCategoryHeader extends StatelessWidget {
  final CategoryModel category;

  EnhancedCategoryHeader({required this.category});

  @override
  Widget build(BuildContext context) {
    final canViewArchived = observeConfigBooleanValue(category.database, 'ExperimentalViewArchivedChannels');
    final currentChannelId = observeCurrentChannelId(category.database);

    return StreamBuilder<bool>(
      stream: canViewArchived.switchMap(
        (canView) => Rx.combineLatest2(
          canView,
          currentChannelId,
          (bool canView, String channelId) => category.observeHasChannels(canView, channelId),
        ),
      ),
      builder: (context, snapshot) {
        final hasChannels = snapshot.data ?? false;

        return CategoryHeader(
          category: category,
          hasChannels: hasChannels,
        );
      },
    );
  }
}
