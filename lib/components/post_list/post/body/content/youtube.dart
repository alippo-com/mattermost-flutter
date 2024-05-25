import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mattermost_flutter/types/post_metadata.dart';
import 'package:mattermost_flutter/utils/images.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/url.dart';
import 'package:mattermost_flutter/constants.dart';

class YouTube extends StatelessWidget {
  final bool isReplyPost;
  final double? layoutWidth;
  final PostMetadata? metadata;

  static const double maxYouTubeImageHeight = 280;
  static const double maxYouTubeImageWidth = 500;

  YouTube({required this.isReplyPost, this.layoutWidth, this.metadata});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final link = metadata?.embeds![0].url;
    final videoId = getYouTubeVideoId(link);
    final dimensions = calculateDimensions(
      maxYouTubeImageHeight,
      maxYouTubeImageWidth,
      layoutWidth ?? (getViewPortWidth(isReplyPost, isTablet(context)) - 6),
    );

    void playYouTubeVideo() {
      if (link == null) {
        return;
      }

      void onError() {
        Fluttertoast.showToast(
          msg: "Unable to open the link.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
        );
      }

      tryOpenURL(link, onError);
    }

    String? imgUrl = metadata?.images?.keys.first;
    imgUrl ??= 'https://i.ytimg.com/vi/$videoId/hqdefault.jpg';

    if (link == null) {
      return Container();
    }

    return GestureDetector(
      onTap: playYouTubeVideo,
      child: Container(
        height: dimensions.height,
        width: dimensions.width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: changeOpacity(Colors.black, 0.24),
          border: Border.all(
            color: changeOpacity(theme.colorScheme.onBackground, 0.08),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: changeOpacity(Colors.black, 0.08),
              offset: Offset(0, 2),
              blurRadius: 3,
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.network(
                imgUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(),
              ),
            ),
            Center(
              child: SvgPicture.asset(
                'assets/images/youtube.svg',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

bool isTablet(BuildContext context) {
  var shortestSide = MediaQuery.of(context).size.shortestSide;
  return shortestSide > 600;
}

double getViewPortWidth(bool isReplyPost, bool isTablet) {
  // Implement the logic to get the viewport width based on isReplyPost and isTablet
  return 0.0; // Placeholder value
}

String? getYouTubeVideoId(String? url) {
  // Implement the logic to extract the YouTube video ID from the URL
  return null; // Placeholder value
}

void tryOpenURL(String url, Function onError) {
  // Implement the logic to open the URL, with error handling
}
