import 'dart:async';

class NavigationStore {
  List<String> _screensInStack = [];
  List<String> _modalsInStack = [];
  String _visibleTab = 'Home';
  bool _tosOpen = false;

  void reset() {
    _screensInStack.clear();
    _modalsInStack.clear();
    _visibleTab = 'Home';
    _tosOpen = false;
  }

  void addModalToStack(String modalId) {
    removeModalFromStack(modalId);
    _screensInStack.insert(0, modalId);
    _modalsInStack.insert(0, modalId);
  }

  void addScreenToStack(String screenId) {
    _screensInStack.remove(screenId);
    _screensInStack.insert(0, screenId);
  }

  void clearScreensFromStack() {
    _screensInStack.clear();
  }

  List<String> getModalsInStack() => _modalsInStack;

  List<String> getScreensInStack() => _screensInStack;

  String getVisibleModal() => _modalsInStack.isNotEmpty ? _modalsInStack.first : null;

  String getVisibleScreen() => _screensInStack.isNotEmpty ? _screensInStack.first : null;

  String getVisibleTab() => _visibleTab;

  bool hasModalsOpened() => _modalsInStack.isNotEmpty;

  bool isToSOpen() => _tosOpen;

  void popTo(String screenId) {
    int index = _screensInStack.indexOf(screenId);
    if (index > -1) {
      _screensInStack.removeRange(0, index);
    }
  }

  void removeScreenFromStack(String screenId) {
    _screensInStack.remove(screenId);
  }

  void removeModalFromStack(String modalId) {
    int indexInStack = _screensInStack.indexOf(modalId);
    if (indexInStack > -1) {
      _screensInStack.removeRange(0, indexInStack + 1);
    }

    int index = _modalsInStack.indexOf(modalId);
    if (index > -1) {
      _modalsInStack.removeAt(index);
    }
  }

  void setToSOpen(bool open) {
    _tosOpen = open;
  }

  void setVisibleTab(String tab) {
    _visibleTab = tab;
  }
}

final NavigationStore navigationStore = NavigationStore();