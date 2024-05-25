// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:mattermost_flutter/constants.dart' as constants;
import 'package:mattermost_flutter/queries/app/global.dart' as global_queries;
import 'package:mattermost_flutter/components/emoji_picker/picker/header/skintone_selector.dart';

class SkinToneSelectorWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: global_queries.observeTutorialWatched(constants.Tutorial.EMOJI_SKIN_SELECTOR),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: \${snapshot.error}');
        } else {
          return SkinToneSelector(tutorialWatched: snapshot.data);
        }
      },
    );
  }
}
