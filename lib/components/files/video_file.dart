import 'package:flutter/material.dart';
import 'package:mattermost_flutter/actions/local/file.dart';
import 'package:mattermost_flutter/actions/remote/file.dart';
import 'package:mattermost_flutter/components/compass_icon.dart';
import 'package:mattermost_flutter/components/progressive_image.dart';
import 'package:mattermost_flutter/context/server.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/utils/file.dart';
import 'package:mattermost_flutter/utils/images.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/components/file_icon.dart';

import 'package:flutter/services.dart';

class VideoFile extends StatefulWidget {
  final int index;
  final FileInfo file;
  final bool inViewPort;
  final bool isSingleImage;
  final BoxFit resizeMode;
  final double wrapperWidth;
  final Function(int idx, FileInfo file) updateFileForGallery;

  const VideoFile({
    Key? key,
    required this.index,
    required this.file,
    this.inViewPort = false,
    this.isSingleImage = false,
    this.resizeMode = BoxFit.cover,
    required this.wrapperWidth,
    required this.updateFileForGallery,
  }) : super(key: key);

  @override
  _VideoFileState createState() => _VideoFileState();
}

class _VideoFileState extends State<VideoFile> {
  bool failed = false;
  late FileInfo video;
  late double viewPortHeight;
  late Size dimensions;
  late Theme theme;
  late bool mounted;

  @override
  void initState() {
    super.initState();
    video = widget.file;
    dimensions = MediaQuery.of(context).size;
    theme = Theme.of(context);
    viewPortHeight = (dimensions.height > dimensions.width ? dimensions.height : dimensions.width) * 0.45;
    mounted = true;
    _getThumbnail();
  }

  @override
  void dispose() {
    mounted = false;
    super.dispose();
  }

  Future<void> _getThumbnail() async {
    final data = widget.file;
    try {
      final exists = data.miniPreview != null ? await fileExists(data.miniPreview!) : false;
      if (data.miniPreview == null || !exists) {
        final videoUrl = buildFileUrl(useServerUrl(), data.id);
        final thumbnailData = await _createThumbnail(videoUrl);
        data.miniPreview = thumbnailData.uri;
        data.height = thumbnailData.height;
        data.width = thumbnailData.width;
        updateLocalFile(useServerUrl(), data);

        if (mounted) {
          setState(() {
            video = data;
            failed = false;
          });
        }
            }
    } catch (error) {
      data.miniPreview = buildFilePreviewUrl(useServerUrl(), data.id);
      if (mounted) {
        setState(() {
          video = data;
        });
      }
    } finally {
      if (data.width == null) {
        data.height = widget.wrapperWidth;
        data.width = widget.wrapperWidth;
      }
      final tw = calculateDimensions(
        data.height,
        data.width,
        dimensions.width - 60, // size of the gallery header probably best to set that as a constant
        dimensions.height,
      );
      data.height = tw.height;
      data.width = tw.width;
      widget.updateFileForGallery(widget.index, data);
    }
  }

  Future<_ThumbnailData> _createThumbnail(String videoUrl) async {
    final Map<String, dynamic> args = {'url': videoUrl, 'timeStamp': 2000};
    final Map<String, dynamic> result = await MethodChannel('mattermost_managed').invokeMethod('createThumbnail', args);
    return _ThumbnailData(result['path'], result['height'], result['width']);
  }

  void _handleError() {
    setState(() {
      failed = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final style = _getStyleSheet(theme);

    final imageDimensions = widget.isSingleImage
        ? calculateDimensions(video.height ?? widget.wrapperWidth, video.width ?? widget.wrapperWidth, widget.wrapperWidth, viewPortHeight)
        : null;

    Widget thumbnail = ProgressiveImage(
      id: widget.file.id,
      style: imageDimensions != null ? imageDimensions.size : style['imagePreview'],
      onError: _handleError,
      resizeMode: widget.resizeMode,
      imageUri: video.miniPreview,
      inViewPort: widget.inViewPort,
    );

    if (failed) {
      thumbnail = Container(
        key: ValueKey('failedImage'),
        height: widget.isSingleImage ? null : double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: changeOpacity(theme.centerChannelColor, 0.2), width: 1),
          borderRadius: BorderRadius.circular(4),
        ),
        alignment: Alignment.center,
        child: FileIcon(file: widget.file, failed: true),
      );
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        overflow: Overflow.clip,
      ),
      child: Stack(
        children: [
          if (!widget.isSingleImage && !failed)
            Container(
              constraints: BoxConstraints.expand(height: double.infinity),
              padding: EdgeInsets.only(bottom: '100%'),
            ),
          thumbnail,
          Center(
            child: Container(
              decoration: BoxDecoration(
                color: changeOpacity(Colors.black, 0.16),
                borderRadius: BorderRadius.circular(20),
              ),
              child: CompassIcon(
                color: changeOpacity(Colors.white, 0.8),
                name: 'play',
                size: 40,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getStyleSheet(ThemeData theme) {
    return {
      'imagePreview': BoxDecoration(
        position: DecorationPosition.background,
      ),
      'fileImageWrapper': BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        overflow: Overflow.clip,
      ),
      'boxPlaceholder': BoxDecoration(
        paddingBottom: '100%',
      ),
      'failed': BoxDecoration(
        alignment: Alignment.center,
        border: Border.all(color: changeOpacity(theme.centerChannelColor, 0.2), width: 1),
        borderRadius: BorderRadius.circular(4),
      ),
      'playContainer': BoxDecoration(
        alignment: Alignment.center,
        position: DecorationPosition.background,
      ),
      'play': BoxDecoration(
        color: changeOpacity(Colors.black, 0.16),
        borderRadius: BorderRadius.circular(20),
      ),
    };
  }
}

class _ThumbnailData {
  final String uri;
  final double height;
  final double width;

  _ThumbnailData(this.uri, this.height, this.width);
}
