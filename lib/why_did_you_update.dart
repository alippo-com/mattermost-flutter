import 'package:flutter/widgets.dart';

class UseDidUpdate {
  bool _hasMounted = false;
  void Function() callback;
  List<Object> dependencies;

  UseDidUpdate(this.callback, {this.dependencies = const []});

  void _effect() {
    if (_hasMounted) {
      callback();
    } else {
      _hasMounted = true;
    }
  }

  void updateDependencies(List<Object> newDeps) {
    if (!listEquals(newDeps, dependencies)) {
      dependencies = newDeps;
      _effect();
    }
  }
}