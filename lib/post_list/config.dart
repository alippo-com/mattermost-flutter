
// mattermost_flutter
// See LICENSE.txt for license information.

class Config {
  static const int initialBatchToRender = 10;
  static const Map<String, dynamic> scrollPositionConfig = {
    'minIndexForVisible': 0,
    'autoscrollToTopThreshold': 60,
  };
  static const Map<String, dynamic> viewabilityConfig = {
    'itemVisiblePercentThreshold': 50,
    'minimumViewTime': 500,
  };
}
