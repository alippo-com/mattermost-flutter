
import 'package:flutter/material.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/file.dart';
import 'package:mattermost_flutter/utils/images.dart';
import 'package:mattermost_flutter/utils/url.dart';
import 'package:mattermost_flutter/utils/general.dart';
import 'package:mattermost_flutter/components/files/file_icon.dart';
import 'package:mattermost_flutter/components/progressive_image.dart';
import 'package:mattermost_flutter/context/gallery.dart';
import 'package:mattermost_flutter/hooks/device.dart';
import 'package:mattermost_flutter/hooks/gallery.dart';

class AttachmentImage extends StatefulWidget {
  final PostImage imageMetadata;
  final String imageUrl;
  final double? layoutWidth;
  final String location;
  final String postId;
  final ThemeModel theme;

  const AttachmentImage({
    required this.imageMetadata,
    required this.imageUrl,
    this.layoutWidth,
    required this.location,
    required this.postId,
    required this.theme,
  });

  @override
  _AttachmentImageState createState() => _AttachmentImageState();
}

class _AttachmentImageState extends State<AttachmentImage> {
  bool _error = false;
  late String _fileId;
  late bool _isTablet;
  late double _height;
  late double _width;
  late ThemeModel _theme;

  @override
  void initState() {
    super.initState();
    _fileId = generateId('uid');
    _isTablet = useIsTablet();
    final dimensions = calculateDimensions(widget.imageMetadata.height, widget.imageMetadata.width, widget.layoutWidth ?? getViewPortWidth(false, _isTablet));
    _height = dimensions['height'];
    _width = dimensions['width'];
    _theme = widget.theme;
  }

  void _onError() {
    setState(() {
      _error = true);
    });
  }

  void _onPress() {
    final GalleryItemType item = GalleryItemType(
      id: _fileId,
      postId: widget.postId,
      uri: widget.imageUrl,
      width: widget.imageMetadata.width,
      height: widget.imageMetadata.height,
      name: extractFilenameFromUrl(widget.imageUrl) ?? 'attachmentImage.png',
      mimeType: lookupMimeType(widget.imageUrl) ?? 'image/png',
      type: 'image',
      lastPictureUpdate: 0,
    );
    openGalleryAtIndex('${widget.postId}-AttachmentImage-${widget.location}', 0, [item]);
  }

  @override
  Widget build(BuildContext context) {
    if (_error || !isValidUrl(widget.imageUrl) || isGifTooLarge(widget.imageMetadata)) {
      return Container(
        decoration: BoxDecoration(
          border: Border.all(color: changeOpacity(_theme.centerChannelColor, 0.2)),
        ),
        height: _height,
        child: Center(
          child: FileIcon(failed: true),
        ),
      );
    }

    final style = getStyleSheet(_theme);

    return GalleryInit(
      galleryIdentifier: '${widget.postId}-AttachmentImage-${widget.location}',
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        width: _width,
        decoration: BoxDecoration(
          border: Border.all(color: changeOpacity(_theme.centerChannelColor, 0.1)),
          borderRadius: BorderRadius.circular(2),
        ),
        child: GestureDetector(
          onTap: _onPress,
          child: ProgressiveImage(
            imageUri: widget.imageUrl,
            onError: _onError,
            id: _fileId,
            imageStyle: style['attachmentMargin'],
            style: BoxDecoration(
              borderRadius: BorderRadius.circular(3),
              margin: EdgeInsets.symmetric(vertical: 1),
            ),
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> getStyleSheet(ThemeModel theme) {
    return {
      'attachmentMargin': EdgeInsets.fromLTRB(2.5, 2.5, 5, 5),
      'container': EdgeInsets.only(top: 5),
      'imageContainer': BoxDecoration(
        border: Border.all(color: changeOpacity(theme.centerChannelColor, 0.1)),
        borderRadius: BorderRadius.circular(2),
      ),
      'image': BoxDecoration(
        alignItems: Alignment.center,
        borderRadius: BorderRadius.circular(3),
        justifyContent: Alignment.center,
        margin: EdgeInsets.symmetric(vertical: 1),
      ),
    };
  }
}
