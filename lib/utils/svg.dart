
// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:path_drawing/path_drawing.dart';

PathMetric svgM(double x, double y) {
  Path path = Path();
  path.moveTo(x, y);
  return path.computeMetrics().first;
}

PathMetric svgL(double x, double y) {
  Path path = Path();
  path.lineTo(x, y);
  return path.computeMetrics().first;
}

PathMetric svgArc(double toX, double toY, double radius) {
  Path path = Path();
  path.arcTo(Rect.fromCircle(center: Offset(toX, toY), radius: radius), 0, 3.14, false);
  return path.computeMetrics().first;
}

String z = 'z';

String constructRectangularPathWithBorderRadius(
    TutorialItemBounds parentBounds,
    TutorialItemBounds itemBounds,
    double borderRadius = 0,
) {
  final startX = itemBounds.startX;
  final startY = itemBounds.startY;
  final endX = itemBounds.endX;
  final endY = itemBounds.endY;
  return [
    svgM(parentBounds.startX, parentBounds.startY),
    svgL(parentBounds.startX, parentBounds.endY),
    svgL(parentBounds.endX, parentBounds.endY),
    svgL(parentBounds.endX, parentBounds.startY),
    z,
    svgM(startX, startY + borderRadius),
    svgL(startX, endY - borderRadius),
    svgArc(startX + borderRadius, endY, borderRadius),
    svgL(endX - borderRadius, endY),
    svgArc(endX, endY - borderRadius, borderRadius),
    svgL(endX, startY + borderRadius),
    svgArc(endX - borderRadius, startY, borderRadius),
    svgL(startX + borderRadius, startY),
    svgArc(startX, startY + borderRadius, borderRadius),
  ].join(' ');
}

class TutorialItemBounds {
  final double startX, startY, endX, endY;

  TutorialItemBounds(this.startX, this.startY, this.endX, this.endY);
}
  