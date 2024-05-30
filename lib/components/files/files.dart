
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mattermost_flutter/components/file.dart'; // Custom component
import 'package:mattermost_flutter/constants.dart';
import 'package:mattermost_flutter/context/gallery.dart';
import 'package:mattermost_flutter/hooks/device.dart';
import 'package:mattermost_flutter/hooks/files.dart';
import 'package:mattermost_flutter/utils/file.dart';
import 'package:mattermost_flutter/utils/gallery.dart';
import 'package:mattermost_flutter/utils/images.dart';
import 'package:mattermost_flutter/utils/tap.dart';

class Files extends StatefulWidget {
  final bool canDownloadFiles;
  final bool? failed;
  final List<FileInfo> filesInfo;
  final bool isReplyPost;
  final double? layoutWidth;
  final String location;
  final String postId;
  final Map<String, dynamic> postProps;
  final bool publicLinkEnabled;

  const Files({
    Key? key,
    required this.canDownloadFiles,
    this.failed,
    required this.filesInfo,
    required this.isReplyPost,
    this.layoutWidth,
    required this.location,
    required this.postId,
    required this.postProps,
    required this.publicLinkEnabled,
  }) : super(key: key);

  @override
  _FilesState createState() => _FilesState();
}

class _FilesState extends State<Files> {
  late String galleryIdentifier;
  bool inViewPort = false;
  late bool isTablet;
  late List<FileInfo> imageAttachments;
  late List<FileInfo> nonImageAttachments;
  late List<FileInfo> filesForGallery;

  @override
  void initState() {
    super.initState();
    galleryIdentifier = '${widget.postId}-fileAttachments-${widget.location}';
    isTablet = useIsTablet();
    final attachments = useImageAttachments(widget.filesInfo, widget.publicLinkEnabled);
    imageAttachments = attachments['images'];
    nonImageAttachments = attachments['nonImages'];
    filesForGallery = [...imageAttachments, ...nonImageAttachments];

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      DeviceEventEmitter().addListener(Events.ITEM_IN_VIEWPORT, (viewableItems) {
        if (viewableItems.containsKey('${widget.location}-${widget.postId}')) {
          setState(() {
            inViewPort = true;
          });
        }
      });
    });
  }

  int attachmentIndex(String fileId) {
    return filesForGallery.indexWhere((file) => file.id == fileId);
  }

  void handlePreviewPress(int idx) {
    final items = filesForGallery.map((f) => fileToGalleryItem(f, f.userId, widget.postProps)).toList();
    openGalleryAtIndex(galleryIdentifier, idx, items);
  }

  void updateFileForGallery(int idx, FileInfo file) {
    setState(() {
      filesForGallery[idx] = file;
    });
  }

  bool get isSingleImage => widget.filesInfo.where((f) => isImage(f) || isVideo(f)).length == 1;

  @override
  Widget build(BuildContext context) {
    return GalleryInit(
      galleryIdentifier: galleryIdentifier,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        decoration: widget.failed == true ? BoxDecoration(opacity: 0.5) : null,
        child: Column(
          children: [
            renderImageRow(),
            ...renderItems(nonImageAttachments),
          ],
        ),
      ),
    );
  }

  Widget renderImageRow() {
    if (imageAttachments.isEmpty) {
      return SizedBox.shrink();
    }

    final visibleImages = imageAttachments.take(MAX_VISIBLE_ROW_IMAGES).toList();
    final portraitPostWidth = widget.layoutWidth ?? (getViewPortWidth(widget.isReplyPost, isTablet) - 6);

    int? nonVisibleImagesCount;
    if (imageAttachments.length > MAX_VISIBLE_ROW_IMAGES) {
      nonVisibleImagesCount = imageAttachments.length - MAX_VISIBLE_ROW_IMAGES;
    }

    return Row(
      children: renderItems(visibleImages, nonVisibleImagesCount, true),
    );
  }

  List<Widget> renderItems(List<FileInfo> items, [int? moreImagesCount, bool includeGutter = false]) {
    List<Widget> widgets = [];
    for (int idx = 0; idx < items.length; idx++) {
      final file = items[idx];
      final nonVisibleImagesCount = (moreImagesCount != null && idx == MAX_VISIBLE_ROW_IMAGES - 1) ? moreImagesCount : null;
      final containerStyle = items.length > 1 ? [styles.container] : [];
      if (idx != 0 && includeGutter) {
        containerStyle.add(styles.gutter);
      }
      widgets.add(
        Container(
          key: ValueKey(file.id),
          margin: EdgeInsets.only(top: 10),
          child: File(
            galleryIdentifier: galleryIdentifier,
            canDownloadFiles: widget.canDownloadFiles,
            file: file,
            index: attachmentIndex(file.id!),
            onPress: handlePreviewPress,
            isSingleImage: isSingleImage,
            nonVisibleImagesCount: nonVisibleImagesCount,
            publicLinkEnabled: widget.publicLinkEnabled,
            updateFileForGallery: updateFileForGallery,
            wrapperWidth: widget.layoutWidth ?? (getViewPortWidth(widget.isReplyPost, isTablet) - 6),
            inViewPort: inViewPort,
          ),
        ),
      );
    }
    return widgets;
  }
}

final styles = {
  'row': BoxDecoration(
    flex: 1,
    flexDirection: Axis.horizontal,
    marginTop: 5,
  ),
  'container': BoxDecoration(
    flex: 1,
  ),
  'gutter': BoxDecoration(
    marginLeft: 8,
  ),
  'failed': BoxDecoration(
    opacity: 0.5,
  ),
  'marginTop': BoxDecoration(
    marginTop: 10,
  ),
};
