import 'package:flutter/material.dart';
import 'package:mattermost_flutter/components/files/file_icon.dart';
import 'package:mattermost_flutter/components/files/image_file.dart';
import 'package:mattermost_flutter/components/files/video_file.dart';
import 'package:mattermost_flutter/utils/file.dart';
import 'package:mattermost_flutter/types/file_info.dart';

const double ICON_SIZE = 72.0;

class Icon extends StatelessWidget {
  final FileInfo fileInfo;

  const Icon({Key? key, required this.fileInfo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isImage(fileInfo)) {
      return Container(
        height: ICON_SIZE,
        width: ICON_SIZE,
        child: ImageFile(
          file: fileInfo,
          inViewPort: true,
          resizeMode: BoxFit.cover,
        ),
      );
    } else if (isVideo(fileInfo)) {
      return Container(
        height: ICON_SIZE,
        width: ICON_SIZE,
        child: VideoFile(
          file: fileInfo,
          resizeMode: BoxFit.cover,
          inViewPort: true,
          index: 0,
          wrapperWidth: 78,
        ),
      );
    } else {
      return FileIcon(
        file: fileInfo,
        iconSize: ICON_SIZE,
      );
    }
  }
}
