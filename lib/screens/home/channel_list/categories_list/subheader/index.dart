// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:mattermost_flutter/constants.dart';
import 'package:mattermost_flutter/helpers/api/preference.dart';
import 'package:mattermost_flutter/queries/servers/preference.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

import 'subheader.dart';

class SubHeaderProvider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final database = Provider.of<Database>(context);

    final unreadsOnTop = querySidebarPreferences(database, Preferences.CHANNEL_SIDEBAR_GROUP_UNREADS)
        .map((prefs) => getSidebarPreferenceAsBool(prefs, Preferences.CHANNEL_SIDEBAR_GROUP_UNREADS))
        .shareValue();

    return StreamProvider<bool>(
      initialData: false,
      create: (_) => unreadsOnTop,
      child: SubHeader(),
    );
  }
}
