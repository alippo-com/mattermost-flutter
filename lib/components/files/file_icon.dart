import 'package:flutter/material.dart';
import 'package:mattermost_flutter/components/compass_icon.dart';
import 'package:mattermost_flutter/utils/file.dart';
import 'package:mattermost_flutter/types/utils.dart'; // Assuming this is where the @typing directives are imported from

const String BLUE_ICON = '#338AFF';
const String RED_ICON = '#ED522A';
const String GREEN_ICON = '#1CA660';
const String GRAY_ICON = '#999999';
const List<String> FAILED_ICON_NAME_AND_COLOR = ['file-image-broken-outline-large', GRAY_ICON];
const Map<String, List<String>> ICON_NAME_AND_COLOR_FROM_FILE_TYPE = {
  'audio': ['file-audio-outline-large', BLUE_ICON],
  'code': ['file-code-outline-large', BLUE_ICON],
  'image': ['file-image-outline-large', BLUE_ICON],
  'smallImage': ['image-outline', BLUE_ICON],
  'other': ['file-generic-outline-large', BLUE_ICON],
  'patch': ['file-patch-outline-large', BLUE_ICON],
  'pdf': ['file-pdf-outline-large', RED_ICON],
  'presentation': ['file-powerpoint-outline-large', RED_ICON],
  'spreadsheet': ['file-excel-outline-large', GREEN_ICON],
  'text': ['file-text-outline-large', GRAY_ICON],
  'video': ['file-video-outline-large', BLUE_ICON],
  'word': ['file-word-outline-large', BLUE_ICON],
  'zip': ['file-zip-outline-large', BLUE_ICON],
};

class FileIcon extends StatelessWidget {
  final String? backgroundColor;
  final bool defaultImage;
  final bool failed;
  final FileInfo? file;
  final String? iconColor;
  final double iconSize;
  final bool smallImage;

  const FileIcon({
    Key? key,
    this.backgroundColor,
    this.defaultImage = false,
    this.failed = false,
    this.file,
    this.iconColor,
    this.iconSize = 48.0,
    this.smallImage = false,
  }) : super(key: key);

  List<String> getFileIconNameAndColor() {
    if (failed) {
      return FAILED_ICON_NAME_AND_COLOR;
    }

    if (defaultImage) {
      if (smallImage) {
        return ICON_NAME_AND_COLOR_FROM_FILE_TYPE['smallImage'] ?? ['file-generic-outline-large', BLUE_ICON];
      }

      return ICON_NAME_AND_COLOR_FROM_FILE_TYPE['image'] ?? ['file-generic-outline-large', BLUE_ICON];
    }

    if (file != null) {
      final fileType = getFileType(file!);
      return ICON_NAME_AND_COLOR_FROM_FILE_TYPE[fileType] ?? ICON_NAME_AND_COLOR_FROM_FILE_TYPE['other']!;
    }

    return ICON_NAME_AND_COLOR_FROM_FILE_TYPE['other']!;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final List<String> iconNameAndColor = getFileIconNameAndColor();
    final String iconName = iconNameAndColor[0];
    final String defaultIconColor = iconNameAndColor[1];
    final String color = iconColor ?? defaultIconColor;
    final String bgColor = backgroundColor ?? theme.colorScheme.surface.toString();

    return Container(
      decoration: BoxDecoration(
        color: Color(int.parse(bgColor.replaceFirst('#', '0xff'))),
        borderRadius: BorderRadius.circular(4.0),
      ),
      alignment: Alignment.center,
      child: CompassIcon(
        name: iconName,
        size: iconSize,
        color: Color(int.parse(color.replaceFirst('#', '0xff'))),
      ),
    );
  }
}
