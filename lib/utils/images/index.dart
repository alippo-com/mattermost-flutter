// Dart Code: ./mattermost_flutter/lib/utils/images/index.dart

import 'package:flutter/material.dart';
import 'package:mattermost_flutter/types/post_image.dart';

Map<String, double> calculateDimensions(double? height, double? width, {double viewPortWidth = 0, double viewPortHeight = 0}) {
  if (height == null || width == null) {
    return {'height': 0, 'width': 0};
  }

  double ratio = height / width;
  double heightRatio = width / height;

  double imageWidth = width;
  double imageHeight = height;

  if (width >= viewPortWidth) {
    imageWidth = viewPortWidth;
    imageHeight = imageWidth * ratio;
  } else if (width < IMAGE_MIN_DIMENSION) {
    imageWidth = IMAGE_MIN_DIMENSION;
    imageHeight = imageWidth * ratio;
  }

  if ((imageHeight > IMAGE_MAX_HEIGHT || (viewPortHeight != 0 && imageHeight > viewPortHeight)) && viewPortHeight <= IMAGE_MAX_HEIGHT) {
    imageHeight = viewPortHeight != 0 ? viewPortHeight : IMAGE_MAX_HEIGHT;
    imageWidth = imageHeight * heightRatio;
  } else if (imageHeight < IMAGE_MIN_DIMENSION && IMAGE_MIN_DIMENSION * heightRatio <= viewPortWidth) {
    imageHeight = IMAGE_MIN_DIMENSION;
    imageWidth = imageHeight * heightRatio;
  } else if (viewPortHeight != 0 && imageHeight > viewPortHeight) {
    imageHeight = viewPortHeight;
    imageWidth = imageHeight * heightRatio;
  }

  return {'height': imageHeight, 'width': imageWidth};
}

double getViewPortWidth(BuildContext context, bool isReplyPost, {bool tabletOffset = false}) {
  final size = MediaQuery.of(context).size;
  double portraitPostWidth = size.width < size.height ? size.width : size.height - VIEWPORT_IMAGE_OFFSET;

  if (tabletOffset) {
    portraitPostWidth -= View.TABLET_SIDEBAR_WIDTH; // Define TABLET_SIDEBAR_WIDTH in your constants
  }

  if (isReplyPost) {
    portraitPostWidth -= VIEWPORT_IMAGE_REPLY_OFFSET;
  }

  return portraitPostWidth;
}

bool isGifTooLarge(PostImage? imageMetadata) {
  if (imageMetadata?.format != 'gif') {
    // Not a gif or from an older server that doesn't count frames
    return false;
  }

  final frameCount = imageMetadata.frameCount ?? 1;
  final height = imageMetadata.height;
  final width = imageMetadata.width;

  // Try to estimate the in-memory size of the gif to prevent the device out of memory
  return width * height * frameCount > MAX_GIF_SIZE;
}
