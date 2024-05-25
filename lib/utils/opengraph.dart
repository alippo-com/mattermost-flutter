// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

class BestImage {
  String secure_url;
  String url;

  BestImage({this.secure_url, this.url});
}

double getDistanceBW2Points(
    Map<String, dynamic> point1, Map<String, dynamic> point2,
    [String xAttr = 'x', String yAttr = 'y']) {
  return math.sqrt(math.pow(point1[xAttr] - point2[xAttr], 2) +
      math.pow(point1[yAttr] - point2[yAttr], 2));
}

BestImage getNearestPoint(
    Map<String, int> pivotPoint, List<Map<String, dynamic>> points,
    [String xAttr = 'x', String yAttr = 'y']) {
  Map<String, dynamic> nearestPoint = {};

  for (var point in points) {
    if (nearestPoint[xAttr] == null || nearestPoint[yAttr] == null) {
      nearestPoint = point;
    } else if (getDistanceBW2Points(point, pivotPoint, xAttr, yAttr) <
        getDistanceBW2Points(nearestPoint, pivotPoint, xAttr, yAttr)) {
      nearestPoint = point;
    }
  }

  return BestImage(
      secure_url: nearestPoint['secure_url'], url: nearestPoint['url']);
}
