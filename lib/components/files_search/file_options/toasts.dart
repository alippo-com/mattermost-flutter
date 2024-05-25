
import 'package:flutter/material.dart';
import 'package:mattermost_flutter/screens/footer/copy_public_link.dart';
import 'package:mattermost_flutter/screens/footer/download_with_action.dart';
import 'package:mattermost_flutter/types/screens/gallery.dart';

class Toasts extends StatelessWidget {
  final GalleryAction action;
  final FileInfo? fileInfo;
  final void Function(GalleryAction) setAction;

  const Toasts({
    required this.action,
    required this.fileInfo,
    required this.setAction,
  });

  @override
  Widget build(BuildContext context) {
    GalleryItemType galleryItem = fileInfo != null
        ? GalleryItemType(
            type: fileInfo!.mimeType.startsWith('image/') ? 'image' : 'file',
            ...fileInfo)
        : GalleryItemType(type: 'file');

    switch (action) {
      case GalleryAction.downloading:
        return DownloadWithAction(
          action: action,
          galleryView: false,
          item: galleryItem,
          setAction: setAction,
        );
      case GalleryAction.copying:
        return CopyPublicLink(
          galleryView: false,
          item: galleryItem,
          setAction: setAction,
        );
      default:
        return SizedBox.shrink();
    }
  }
}
