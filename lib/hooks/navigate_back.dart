// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:mattermost_flutter/types/navigation.dart';

const BACK_BUTTON = 'RNN.back';

void useBackNavigation(Function callback) {
  useEffect(() {
    final backListener = Navigation.events().registerNavigationButtonPressedListener((buttonId) {
      if (buttonId == BACK_BUTTON) {
        callback();
      }
    });

    return () => backListener.remove();
  }, [callback]);
}

void useEffect(Function effect, List<dynamic> dependencies) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    effect();
  });
}
