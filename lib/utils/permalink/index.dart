// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:mattermost_flutter/constants/screens.dart';
import 'package:mattermost_flutter/screens/navigation.dart';
import 'package:mattermost_flutter/utils/theme.dart';

bool showingPermalink = false;

Future<void> displayPermalink(String teamName, String postId, {bool openAsPermalink = true}) async {
  SystemChannels.textInput.invokeMethod('TextInput.hide');
  
  if (showingPermalink) {
    await dismissAllModals();
  }

  final screen = Screens.PERMALINK;
  final passProps = {
    'isPermalink': openAsPermalink,
    'teamName': teamName,
    'postId': postId,
  };

  final options = {
    'modalPresentationStyle': Platform.isIOS ? 'overFullScreen' : 'overCurrentContext',
    'layout': {
      'componentBackgroundColor': changeOpacity('#000000', 0.2),
    },
  };

  showingPermalink = true;
  showModalOverCurrentContext(screen, passProps, options);
}

void closePermalink() {
  showingPermalink = false;
}
