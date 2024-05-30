import 'package:flutter/material.dart';
import 'package:mattermost_flutter/components/files/file_icon.dart';
import 'package:mattermost_flutter/components/progressive_image.dart';
import 'package:mattermost_flutter/context/gallery.dart';
import 'package:mattermost_flutter/context/server.dart';
import 'package:mattermost_flutter/hooks/did_update.dart';
import 'package:mattermost_flutter/utils/file.dart';
import 'package:mattermost_flutter/utils/gallery.dart';
import 'package:mattermost_flutter/utils/general.dart';
import 'package:mattermost_flutter/utils/images.dart';
import 'package:mattermost_flutter/utils/theme.dart';

class ImagePreview extends StatefulWidget {
  final String? expandedLink;
  final bool isReplyPost;
  final String link;
  final double? layoutWidth;
  final String location;
  final PostMetadata? metadata;
  final String postId;
  final Theme theme;

  ImagePreview({
    this.expandedLink,
    required this.isReplyPost,
    required this.link,
    this.layoutWidth,
    required this.location,
    this.metadata,
    required this.postId,
    required this.theme,
  });

  @override
  _ImagePreviewState createState() => _ImagePreviewState();
}

class _ImagePreviewState extends State<ImagePreview> {
  late String imageUrl;
  late String fileId;
  bool error = false;

  @override
  void initState() {
    super.initState();
    fileId = generateId('uid');
    imageUrl = widget.expandedLink ?? widget.link;
  }

  @override
  void didUpdateWidget(covariant ImagePreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.expandedLink != null && widget.expandedLink != imageUrl) {
      setState(() {
        imageUrl = widget.expandedLink!;
      });
    } else if (widget.link != imageUrl) {
      setState(() {
        imageUrl = widget.link;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!isImageLink(widget.link) && widget.expandedLink == null) {
      getRedirectLocation(useServerUrl(), widget.link);
    }
  }

  void onError() {
    setState(() {
      error = true;
    });
  }

  void onPress() {
    final item = GalleryItemType(
      id: fileId,
      postId: widget.postId,
      uri: imageUrl,
      width: widget.metadata?.images?[widget.link]?.width ?? 0,
      height: widget.metadata?.images?[widget.link]?.height ?? 0,
      name: extractFilenameFromUrl(imageUrl) ?? 'imagePreview.png',
      mimeType: lookupMimeType(imageUrl) ?? 'image/png',
      type: 'image',
      lastPictureUpdate: 0,
    );
    openGalleryAtIndex('${widget.postId}-ImagePreview-${widget.location}', 0, [item]);
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = useIsTablet();
    final imageProps = widget.metadata?.images?[widget.link];
    final dimensions = calculateDimensions(
      imageProps?.height ?? 0,
      imageProps?.width ?? 0,
      widget.layoutWidth ?? getViewPortWidth(widget.isReplyPost, isTablet),
    );

    if (error || !isValidUrl(widget.expandedLink ?? widget.link) || isGifTooLarge(imageProps)) {
      return Container(
        alignment: Alignment.centerLeft,
        margin: const EdgeInsets.only(bottom: 6, top: 10),
        decoration: BoxDecoration(
          border: Border.all(color: changeOpacity(widget.theme.centerChannelColor, 0.2)),
        ),
        height: dimensions.height,
        child: Container(
          width: dimensions.width,
          height: dimensions.height,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
          ),
          child: FileIcon(
            failed: true,
          ),
        ),
      );
    }

    final galleryItem = useGalleryItem(
      '${widget.postId}-ImagePreview-${widget.location}',
      0,
      onPress,
    );

    return GalleryInit(
      galleryIdentifier: '${widget.postId}-ImagePreview-${widget.location}',
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: dimensions.height,
        alignment: Alignment.centerLeft,
        margin: const EdgeInsets.only(bottom: 6, top: 10),
        child: GestureDetector(
          onTap: galleryItem.onGestureEvent,
          child: ProgressiveImage(
            forwardRef: galleryItem.ref,
            id: fileId,
            imageUri: imageUrl,
            onError: onError,
            resizeMode: BoxFit.contain,
            width: dimensions.width,
            height: dimensions.height,
          ),
        ),
      ),
    );
  }
}
