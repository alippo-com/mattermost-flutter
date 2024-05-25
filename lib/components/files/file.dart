import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/hooks/gallery_item.dart';
import 'package:mattermost_flutter/utils/file.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/components/touchable_with_feedback.dart';
import 'package:mattermost_flutter/components/document_file.dart';
import 'package:mattermost_flutter/components/file_icon.dart';
import 'package:mattermost_flutter/components/file_info.dart';
import 'package:mattermost_flutter/components/file_options_icon.dart';
import 'package:mattermost_flutter/components/image_file.dart';
import 'package:mattermost_flutter/components/image_file_overlay.dart';
import 'package:mattermost_flutter/components/video_file.dart';

class FileComponent extends StatelessWidget {
  final bool canDownloadFiles;
  final FileInfo file;
  final String galleryIdentifier;
  final int index;
  final bool inViewPort;
  final bool isSingleImage;
  final int nonVisibleImagesCount;
  final Function(int index) onPress;
  final bool publicLinkEnabled;
  final String? channelName;
  final Function(FileInfo fileInfo)? onOptionsPress;
  final bool? optionSelected;
  final double? wrapperWidth;
  final bool? showDate;
  final Function(int idx, FileInfo file) updateFileForGallery;
  final bool? asCard;

  FileComponent({
    required this.canDownloadFiles,
    required this.file,
    required this.galleryIdentifier,
    required this.index,
    required this.inViewPort,
    this.isSingleImage = false,
    this.nonVisibleImagesCount = 0,
    required this.onPress,
    required this.publicLinkEnabled,
    this.channelName,
    this.onOptionsPress,
    this.optionSelected,
    this.wrapperWidth = 300,
    this.showDate = false,
    required this.updateFileForGallery,
    this.asCard = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeModel>(context);
    final style = getStyleSheet(theme);

    final document = GlobalKey<DocumentFileState>();

    void handlePreviewPress() {
      if (document.currentState != null) {
        document.currentState!.handlePreviewPress();
      } else {
        onPress(index);
      }
    }

    final galleryItem = useGalleryItem(galleryIdentifier, index, handlePreviewPress);

    void handleOnOptionsPress() {
      if (onOptionsPress != null) {
        onOptionsPress!(file);
      }
    }

    Widget renderCardWithImage(Widget fileIcon) {
      final fileInfo = FileInfo(
        file: file,
        showDate: showDate,
        channelName: channelName,
        onPress: handlePreviewPress,
      );

      return Container(
        decoration: BoxDecoration(
          border: Border.all(color: changeOpacity(theme.centerChannelColor, 0.24)),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.all(8),
              child: fileIcon,
            ),
            Expanded(child: fileInfo),
            if (onOptionsPress != null)
              FileOptionsIcon(
                onPress: handleOnOptionsPress,
                selected: optionSelected ?? false,
              ),
          ],
        ),
      );
    }

    Widget fileComponent;
    if (isVideo(file) && publicLinkEnabled) {
      final renderVideoFile = GestureDetector(
        onTap: galleryItem.onGestureEvent,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: VideoFile(
            file: file,
            key: galleryItem.ref,
            inViewPort: inViewPort,
            isSingleImage: isSingleImage,
            wrapperWidth: wrapperWidth,
            updateFileForGallery: updateFileForGallery,
            index: index,
          ),
        ),
      );

      fileComponent = asCard ? renderCardWithImage(renderVideoFile) : renderVideoFile;
    } else if (isImage(file)) {
      final renderImageFile = GestureDetector(
        onTap: galleryItem.onGestureEvent,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: ImageFile(
            file: file,
            key: galleryItem.ref,
            inViewPort: inViewPort,
            isSingleImage: isSingleImage,
            wrapperWidth: wrapperWidth,
          ),
        ),
      );

      fileComponent = asCard ? renderCardWithImage(renderImageFile) : renderImageFile;
    } else if (isDocument(file)) {
      final renderDocumentFile = DocumentFile(
        key: document,
        canDownloadFiles: canDownloadFiles,
        file: file,
      );

      final fileInfo = FileInfo(
        file: file,
        showDate: showDate,
        channelName: channelName,
        onPress: handlePreviewPress,
      );

      fileComponent = Container(
        decoration: BoxDecoration(
          border: Border.all(color: changeOpacity(theme.centerChannelColor, 0.24)),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            Container(
              margin: const EdgeInsets.all(8),
              child: renderDocumentFile,
            ),
            Expanded(child: fileInfo),
            if (onOptionsPress != null)
              FileOptionsIcon(
                onPress: handleOnOptionsPress,
                selected: optionSelected ?? false,
              ),
          ],
        ),
      );
    } else {
      final touchableWithPreview = TouchableWithFeedback(
        onPress: handlePreviewPress,
        type: TouchableType.opacity,
        child: FileIcon(file: file),
      );

      fileComponent = renderCardWithImage(touchableWithPreview);
    }
    return fileComponent;
  }

  Map<String, dynamic> getStyleSheet(ThemeModel theme) {
    return {
      'fileWrapper': BoxDecoration(
        border: Border.all(color: changeOpacity(theme.centerChannelColor, 0.24), width: 1),
        borderRadius: BorderRadius.circular(4),
      ),
      'iconWrapper': EdgeInsets.all(8),
      'imageVideo': BoxDecoration(
        height: 40,
        width: 40,
        margin: EdgeInsets.all(4),
      ),
    };
  }
}
