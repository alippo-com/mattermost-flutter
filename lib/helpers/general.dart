// mattermost_flutter
// See LICENSE.txt for license information.

import 'dart:async';

/// Debounce function modified for Dart using closure and Timer.
void Function(List<dynamic>) debounce(
    Function(List<dynamic>) func, 
    Duration wait, 
    {bool immediate = false, 
    Function? cb}) {

  Timer? timer;

  return (List<dynamic> args) {
    void runLater() {
      timer = null;
      if (!immediate) {
        func(args);
        cb?.call();
      }
    }

    bool callNow = immediate && timer == null;
    timer?.cancel();
    timer = Timer(wait, runLater);

    if (callNow) {
      func(args);
      cb?.call();
    }
  };
}