// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'dart:async';

Function preventDoubleTap(Function func, [int doublePressDelay = 750]) {
  bool canPressWrapped = true;

  return (args) {
    if (canPressWrapped) {
      canPressWrapped = false;
      Function.apply(func, args);

      Timer(Duration(milliseconds: doublePressDelay), () {
        canPressWrapped = true;
      });
    }
  };
}
