// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:mattermost_flutter/components/compass_icon.dart';
import 'package:mattermost_flutter/components/progressive_image.dart';
import 'package:mattermost_flutter/context/server.dart';
import 'package:mattermost_flutter/utils/gallery.dart';
import 'package:mattermost_flutter/utils/general.dart';
import 'package:mattermost_flutter/utils/images.dart';
import 'package:provider/provider.dart';

class MarkdownTableImage extends StatefulWidget {
  final bool? disabled;
  final Map<String, dynamic> imagesMetadata;
  final String? location;
  final String postId;
  final String? serverURL;
  final String source;

  const MarkdownTableImage({
    Key? key,
    this.disabled,
    required this.imagesMetadata,
    this.location,
    required this.postId,
    this.serverURL,
    required this.source,
  }) : super(key: key);

  @override
  _MarkdownTableImageState createState() => _MarkdownTableImageState();
}

class _MarkdownTableImageState extends State<MarkdownTableImage> {
  late String fileId;
  late bool failed;
  late String galleryIdentifier;
  late String currentServerUrl;

  @override
  void initState() {
    super.initState();
    fileId = generateId('uid');
    failed = isGifTooLarge(widget.imagesMetadata[widget.source]);
    currentServerUrl = context.read<ServerUrlProvider>().serverUrl;
    galleryIdentifier = '${widget.postId}-$fileId-${widget.location}';
  }

  String getImageSource() {
    String uri = widget.source;
    String? server = widget.serverURL ?? currentServerUrl;
    if (uri.startsWith('/')) {
      uri = server + uri;
    }
    return uri;
  }

  Map<String, dynamic> getFileInfo() {
    final metadata = widget.imagesMetadata[widget.source];
    final int height = metadata?['height'] ?? 0;
    final int width = metadata?['width'] ?? 0;
    final String link = Uri.decodeComponent(getImageSource());
    String filename = Uri.parse(link.substring(link.lastIndexOf('/'))).path.replaceFirst('/', '');
    String extension = filename.split('.').last;

    if (extension == filename) {
      final ext = filename.contains('.') ? filename.substring(filename.lastIndexOf('.')) : '.png';
      filename = '$filename$ext';
      extension = ext;
    }

    return {
      'id': fileId,
      'name': filename,
      'extension': extension,
      'has_preview_image': true,
      'post_id': widget.postId,
      'uri': link,
      'width': width,
      'height': height,
    };
  }

  void handlePreviewImage() {
    final file = getFileInfo();
    if (file['uri'] == null) {
      return;
    }
    final item = fileToGalleryItem(file)..['type'] = 'image';
    openGalleryAtIndex(galleryIdentifier, 0, [item]);
  }

  void onLoadFailed() {
    setState(() {
      failed = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget image;

    if (failed) {
      image = CompassIcon(
        name: 'file-image-broken-outline-large',
        size: 24.0,
      );
    } else {
      final dimensions = calculateDimensions(
        widget.imagesMetadata[widget.source]?['height'],
        widget.imagesMetadata[widget.source]?['width'],
        100,
        100,
      );
      final height = dimensions['height'];
      final width = dimensions['width'];
      image = GestureDetector(
        onTap: widget.disabled! ? null : handlePreviewImage,
        child: Container(
          width: width,
          height: height,
          child: ProgressiveImage(
            id: fileId,
            imageUri: widget.source,
            onError: onLoadFailed,
            fit: BoxFit.contain,
          ),
        ),
      );
    }

    return Container(
      alignment: Alignment.center,
      child: image,
    );
  }
}
