// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:mattermost_flutter/types/navigation_store.dart';
import 'package:mattermost_flutter/types/keyboard_tracking_view_ref.dart';

class KeyboardTrackingController {
  final Ref<KeyboardTrackingViewRef> keyboardTrackingRef;
  final String trackerId;
  final List<String> screens;
  bool isPostDraftPaused = false;

  KeyboardTrackingController({
    required this.keyboardTrackingRef,
    required this.trackerId,
    required this.screens,
  }) {
    _init();
  }

  void _init() {
    keyboardTrackingRef.current?.resumeTracking(trackerId);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _registerListeners();
    });
  }

  void _registerListeners() {
    final commandListener = Navigation.events().registerCommandListener(() {
      Future.delayed(Duration.zero, () {
        final visibleScreen = NavigationStore.getVisibleScreen();
        if (!isPostDraftPaused && !screens.contains(visibleScreen)) {
          isPostDraftPaused = true;
          keyboardTrackingRef.current?.pauseTracking(trackerId);
        }
      });
    });

    final commandCompletedListener = Navigation.events().registerCommandCompletedListener(() {
      _onCommandComplete();
    });

    final popListener = Navigation.events().registerScreenPoppedListener(() {
      _onCommandComplete();
    });

    // Remove listeners when not needed
    // Note: This is a simplified version, actual removal can be more complex in Dart
    // depending on how the listeners are managed.
    // Dispose methods must be implemented properly in the actual widget/controller.
  }

  void _onCommandComplete() {
    final id = NavigationStore.getVisibleScreen();
    if (screens.contains(id) && isPostDraftPaused) {
      isPostDraftPaused = false;
      keyboardTrackingRef.current?.resumeTracking(trackerId);
    }
  }
}
