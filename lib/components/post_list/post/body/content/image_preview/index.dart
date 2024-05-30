// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mattermost_flutter/database/database.dart';
import 'package:mattermost_flutter/components/image_preview.dart';
import 'package:mattermost_flutter/types/post_metadata.dart';

class EnhancedImagePreview extends StatelessWidget {
  final PostMetadata? metadata;
  final Database database;

  EnhancedImagePreview({
    required this.metadata,
    required this.database,
  });

  @override
  Widget build(BuildContext context) {
    final link = metadata?.embeds?[0].url;

    final expandedLinkStream = observeExpandedLinks(database).switchMap((expandedLinks) {
      return link != null ? Stream.value(expandedLinks[link]) : Stream.value(null);
    });

    return StreamProvider.value(
      value: expandedLinkStream,
      initialData: null,
      child: ImagePreview(link: link),
    );
  }
}
