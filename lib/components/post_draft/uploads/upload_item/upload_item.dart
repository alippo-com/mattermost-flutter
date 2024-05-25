import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';
import 'package:mattermost_flutter/actions/local/draft.dart';
import 'package:mattermost_flutter/components/files/file_icon.dart';
import 'package:mattermost_flutter/components/files/image_file.dart';
import 'package:mattermost_flutter/components/progress_bar.dart';
import 'package:mattermost_flutter/context/server.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/hooks/did_update.dart';
import 'package:mattermost_flutter/hooks/gallery.dart';
import 'package:mattermost_flutter/managers/draft_upload_manager.dart';
import 'package:mattermost_flutter/utils/file.dart';
import 'package:mattermost_flutter/utils/theme.dart';

import 'upload_remove.dart';
import 'upload_retry.dart';

class UploadItem extends HookWidget {
  final String channelId;
  final String galleryIdentifier;
  final int index;
  final FileInfo file;
  final Function(FileInfo) openGallery;
  final String rootId;

  UploadItem({
    required this.channelId,
    required this.galleryIdentifier,
    required this.index,
    required this.file,
    required this.openGallery,
    required this.rootId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = useTheme();
    final serverUrl = useServerUrl();
    final removeCallback = useRef<Function?>(null);
    final progress = useState(0.0);

    final loading = DraftUploadManager.isUploading(file.clientId!);

    final handlePress = useCallback(() {
      openGallery(file);
    }, [openGallery, file]);

    useEffect(() {
      if (file.clientId != null) {
        removeCallback.current =
            DraftUploadManager.registerProgressHandler(file.clientId!, (p) => progress.value = p);
      }
      return () {
        removeCallback.current?.call();
        removeCallback.current = null;
      };
    }, [file]);

    useDidUpdate(() {
      if (loading && file.clientId != null) {
        removeCallback.current =
            DraftUploadManager.registerProgressHandler(file.clientId!, (p) => progress.value = p);
      }
      return () {
        removeCallback.current?.call();
        removeCallback.current = null;
      };
    }, [file.failed, file.id]);

    final retryFileUpload = useCallback(() {
      if (!file.failed) {
        return;
      }

      final newFile = file.copyWith(failed: false);
      updateDraftFile(serverUrl, channelId, rootId, newFile);
      DraftUploadManager.prepareUpload(serverUrl, newFile, channelId, rootId, newFile.bytesRead);
      DraftUploadManager.registerProgressHandler(newFile.clientId!, (p) => progress.value = p);
    }, [serverUrl, channelId, rootId, file]);

    final galleryItem = useGalleryItem(galleryIdentifier, index, handlePress);
    final filePreviewComponent = useMemo(() {
      if (isImage(file)) {
        return ImageFile(
          file: file,
          forwardRef: galleryItem.ref,
          resizeMode: BoxFit.cover,
        );
      }
      return FileIcon(
        backgroundColor: changeOpacity(theme.centerChannelColor, 0.08),
        iconSize: 60,
        file: file,
      );
    }, [file]);

    return Container(
      key: ValueKey(file.clientId),
      padding: const EdgeInsets.only(left: 12, top: 5),
      child: Column(
        children: [
          Container(
            height: 56,
            width: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
            ),
            child: GestureDetector(
              onTap: galleryItem.onGestureEvent,
              child: AnimatedBuilder(
                animation: galleryItem.animation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: galleryItem.scale.value,
                    child: filePreviewComponent,
                  );
                },
              ),
            ),
          ),
          if (file.failed)
            UploadRetry(onPress: retryFileUpload),
          if (loading && !file.failed)
            Container(
              height: 53,
              width: 53,
              alignment: Alignment.bottomCenter,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: ProgressBar(progress: progress.value, color: theme.buttonBg),
            ),
          UploadRemove(
            clientId: file.clientId!,
            channelId: channelId,
            rootId: rootId,
          ),
        ],
      ),
    );
  }
}
