// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:nozbe_watermelondb/nozbe_watermelondb.dart';
import 'package:mattermost_flutter/queries/servers/system.dart';
import 'package:mattermost_flutter/types/database/database.dart';
import 'custom_status_suggestion.dart';

class CustomStatusSuggestionWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: observeIsCustomStatusExpirySupported(database),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }

        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        return CustomStatusSuggestion(
          isExpirySupported: snapshot.data ?? false,
        );
      },
    );
  }
}
