// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mattermost_flutter/context/gallery.dart';
import 'package:mattermost_flutter/utils/file.dart';
import 'package:mattermost_flutter/utils/gallery.dart';
import 'package:mattermost_flutter/utils/general.dart';
import 'package:mattermost_flutter/utils/images.dart';
import 'package:mattermost_flutter/utils/opengraph.dart';
import 'package:mattermost_flutter/utils/theme.dart';

import 'package:mattermost_flutter/types/screens/gallery.dart';

const MAX_IMAGE_HEIGHT = 150;
const VIEWPORT_IMAGE_OFFSET = 93;
const VIEWPORT_IMAGE_REPLY_OFFSET = 13;

Map<String, dynamic> getStyleSheet(Theme theme) {
  return {
    'imageContainer': BoxDecoration(
      alignItems: Alignment.center,
      border: Border.all(color: changeOpacity(theme.centerChannelColor, 0.2)),
      borderRadius: BorderRadius.circular(3),
      margin: EdgeInsets.only(top: 5),
    ),
    'image': BoxDecoration(
      borderRadius: BorderRadius.circular(3),
    ),
  };
}

double getViewPostWidth(bool isReplyPost, double deviceHeight, double deviceWidth) {
  final deviceSize = deviceWidth > deviceHeight ? deviceHeight : deviceWidth;
  final viewPortWidth = deviceSize - VIEWPORT_IMAGE_OFFSET - (isReplyPost ? VIEWPORT_IMAGE_REPLY_OFFSET : 0);
  final tabletOffset = isTablet() ? ViewConstants.TABLET_SIDEBAR_WIDTH : 0;

  return viewPortWidth - tabletOffset;
}

class OpengraphImage extends HookWidget {
  final bool isReplyPost;
  final double? layoutWidth;
  final String location;
  final PostMetadata? metadata;
  final List<dynamic> openGraphImages;
  final String postId;
  final Theme theme;

  OpengraphImage({
    required this.isReplyPost,
    this.layoutWidth,
    required this.location,
    this.metadata,
    required this.openGraphImages,
    required this.postId,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final fileId = useMemo(() => generateId('uid'), []);
    final dimensions = MediaQuery.of(context).size;
    final style = getStyleSheet(theme);
    final galleryIdentifier = '$postId-OpenGraphImage-$location';

    final bestDimensions = useMemo(() => {
      return {
        'height': MAX_IMAGE_HEIGHT,
        'width': layoutWidth ?? getViewPostWidth(isReplyPost, dimensions.height, dimensions.width),
      };
    }, [isReplyPost, dimensions]);
    final bestImage = getNearestPoint(bestDimensions, openGraphImages, 'width', 'height');
    final imageUrl = bestImage['secure_url'] ?? bestImage['url'];
    final imagesMetadata = metadata?.images;

    var ogImage = imagesMetadata?[imageUrl];
    ogImage ??= openGraphImages.firstWhere((i) => i.url == imageUrl || i.secure_url == imageUrl, orElse: () => null);

    final metaImages = imagesMetadata?.values.toList();
    if ((ogImage?.width == null || ogImage?.height == null) && metaImages != null && metaImages.isNotEmpty) {
      ogImage = metaImages.first;
    }

    var imageDimensions = bestDimensions;
    if (ogImage?.width != null && ogImage?.height != null) {
      imageDimensions = calculateDimensions(
        ogImage.height,
        ogImage.width,
        (layoutWidth ?? getViewPostWidth(isReplyPost, dimensions.height, dimensions.width)) - 20,
      );
    }

    void onPress() {
      final item = GalleryItemType(
        id: fileId,
        postId: postId,
        uri: imageUrl!,
        width: imageDimensions['width'],
        height: imageDimensions['height'],
        name: extractFilenameFromUrl(imageUrl) ?? 'openGraph.png',
        mimeType: lookupMimeType(imageUrl) ?? 'image/png',
        type: 'image',
        lastPictureUpdate: 0,
      );
      openGalleryAtIndex(galleryIdentifier, 0, [item]);
    }

    final source = isValidUrl(imageUrl) ? imageUrl : '';

    final galleryItem = useGalleryItem(galleryIdentifier, 0, onPress);
    return GalleryInit(
      galleryIdentifier: galleryIdentifier,
      child: AnimatedContainer(
        decoration: style['imageContainer'],
        duration: Duration(milliseconds: 300),
        child: GestureDetector(
          onTap: galleryItem.onGestureEvent,
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300),
            child: CachedNetworkImage(
              imageUrl: source!,
              fit: BoxFit.contain,
              height: imageDimensions['height'],
              width: imageDimensions['width'],
              // TODO: Add ref equivalent in Flutter if needed
            ),
          ),
        ),
      ),
    );
  }
}
