
// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

/// Dart class representing the bounds of a tutorial item in the Mattermost environment.
class TutorialItemBounds {
  final double startX;
  final double startY;
  final double endX;
  final double endY;

  TutorialItemBounds({
    required this.startX,
    required this.startY,
    required this.endX,
    required this.endY,
  });
}
