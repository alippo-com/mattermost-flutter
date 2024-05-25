
// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:mattermost_flutter/types/navigation.dart';

typedef Callback = Function();

void useNavButtonPressed(String navButtonId, String componentId, Callback callback, [List<dynamic>? deps]) {
  useEffect(() {
    final unsubscribe = Navigation.events().registerComponentListener({
      navigationButtonPressed: ({required String buttonId}) {
        if (buttonId == navButtonId) {
          callback();
        }
      },
    }, componentId);

    return () => unsubscribe.remove();
  }, deps);
}

void useEffect(Function effect, [List<dynamic>? dependencies]) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    effect();
  });
}
