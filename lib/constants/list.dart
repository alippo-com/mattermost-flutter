
// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

class VisibilityConfigDefaults {
  static const int itemVisiblePercentThreshold = 100;
  static const bool waitForInteraction = true;
}

class VisibilityConfig {
  static const VisibilityConfigDefaults visibilityConfigDefaults = VisibilityConfigDefaults();
  static const String visibilityScrollDown = 'down';
  static const String visibilityScrollUp = 'up';
}
