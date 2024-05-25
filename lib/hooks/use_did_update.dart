import 'package:flutter/material.dart';

class UseDidUpdate {
  bool _hasMount = false;

  void Function() callback;
  List<Object?> deps;

  UseDidUpdate({required this.callback, this.deps = const []});

  void updateDependencies(List<Object?> newDeps) {
    bool depsChanged = false;
    if (newDeps.length != deps.length) {
      depsChanged = true;
    } else {
      for (int i = 0; i < newDeps.length; i++) {
        if (newDeps[i] != deps[i]) {
          depsChanged = true;
          break;
        }
      }
    }

    if (depsChanged) {
      _hasMount = false;
      deps = newDeps;
    }
  }

  void didUpdate() {
    if (_hasMount) {
      callback();
    } else {
      _hasMount = true;
    }
  }
}