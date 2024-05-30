// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/foundation.dart';

typedef void ValueCallback(String value);
typedef bool BoolCallback(String value);

class UseInputPropagation {
  ValueNotifier<String?> waitForValue = ValueNotifier<String?>(null);

  ValueCallback waitToPropagate() {
    return (String value) {
      waitForValue.value = value;
    };
  }

  BoolCallback shouldProcessEvent() {
    return (String newValue) {
      if (defaultTargetPlatform == TargetPlatform.android) {
        return true;
      }
      if (waitForValue.value == null) {
        return true;
      }
      if (newValue == waitForValue.value) {
        waitForValue.value = null;
      }
      return false;
    };
  }

  List<dynamic> getCallbacks() {
    return [waitToPropagate(), shouldProcessEvent()];
  }
}
