// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mattermost_flutter/constants/preferences.dart';
import 'package:mattermost_flutter/helpers/api/preference.dart';
import 'package:mattermost_flutter/queries/servers/preference.dart';
import 'package:mattermost_flutter/queries/servers/system.dart';
import 'package:rxdart/rxdart.dart';

import 'opengraph.dart';

class EnhancedOpengraph extends StatelessWidget {
  final bool removeLinkPreview;

  const EnhancedOpengraph({Key? key, required this.removeLinkPreview}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final database = Provider.of<Database>(context, listen: false);

    return StreamBuilder<bool>(
      stream: _showLinkPreviewsStream(database, removeLinkPreview),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }

        final showLinkPreviews = snapshot.data!;
        return Opengraph(showLinkPreviews: showLinkPreviews);
      },
    );
  }

  Stream<bool> _showLinkPreviewsStream(Database database, bool removeLinkPreview) {
    if (removeLinkPreview) {
      return Stream.value(false);
    }

    final linkPreviewsConfig = observeConfigBooleanValue(database, 'EnableLinkPreviews');
    final linkPreviewPreference = queryDisplayNamePreferences(database, Preferences.LINK_PREVIEW_DISPLAY)
        .map((prefs) => getDisplayNamePreferenceAsBool(prefs, Preferences.LINK_PREVIEW_DISPLAY, true));

    return Rx.combineLatest2(linkPreviewsConfig, linkPreviewPreference, (cfg, pref) {
      return pref && cfg;
    });
  }
}
