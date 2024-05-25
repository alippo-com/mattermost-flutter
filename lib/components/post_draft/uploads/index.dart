import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:mattermost_flutter/components/upload_item.dart';
import 'package:mattermost_flutter/context/gallery.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/managers/draft_upload_manager.dart';
import 'package:mattermost_flutter/utils/gallery.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:reanimated/reanimated.dart';

const double containerHeightMax = 67.0;
const double containerHeightMin = 0.0;
const double errorHeightMax = 20.0;
const double errorHeightMin = 0.0;

class Uploads extends StatefulWidget {
  final String currentUserId;
  final List<FileInfo> files;
  final String uploadFileError;
  final String channelId;
  final String rootId;

  const Uploads({
    Key? key,
    required this.currentUserId,
    required this.files,
    required this.uploadFileError,
    required this.channelId,
    required this.rootId,
  }) : super(key: key);

  @override
  _UploadsState createState() => _UploadsState();
}

class _UploadsState extends State<Uploads> {
  late double errorHeight;
  late double containerHeight;
  late List<FileInfo> filesForGallery;

  @override
  void initState() {
    super.initState();
    errorHeight = errorHeightMin;
    containerHeight = widget.files.isNotEmpty ? containerHeightMax : containerHeightMin;
    filesForGallery = widget.files.where((f) => !f.failed && !DraftUploadManager.isUploading(f.clientId!)).toList();
  }

  @override
  void didUpdateWidget(Uploads oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.uploadFileError.isNotEmpty) {
      setState(() {
        errorHeight = errorHeightMax;
      });
    } else {
      setState(() {
        errorHeight = errorHeightMin;
      });
    }

    if (widget.files.isNotEmpty) {
      setState(() {
        containerHeight = containerHeightMax;
      });
    } else {
      setState(() {
        containerHeight = containerHeightMin;
      });
    }

    filesForGallery = widget.files.where((f) => !f.failed && !DraftUploadManager.isUploading(f.clientId!)).toList();
  }

  void openGallery(FileInfo file) {
    final items = filesForGallery.map((f) => fileToGalleryItem(f, widget.currentUserId)).toList();
    final index = filesForGallery.indexWhere((f) => f.clientId == file.clientId);
    openGalleryAtIndex('${widget.channelId}-uploadedItems-${widget.rootId}', index, items, true);
  }

  List<Widget> buildFilePreviews() {
    return widget.files.map((file) {
      final index = widget.files.indexOf(file);
      return UploadItem(
        channelId: widget.channelId,
        galleryIdentifier: '${widget.channelId}-uploadedItems-${widget.rootId}',
        index: index,
        file: file,
        key: ValueKey(file.clientId),
        openGallery: () => openGallery(file),
        rootId: widget.rootId,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = useTheme(context);
    final style = getStyleSheet(theme);

    return GalleryInit(
      galleryIdentifier: '${widget.channelId}-uploadedItems-${widget.rootId}',
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: containerHeight,
            padding: EdgeInsets.only(bottom: widget.files.isNotEmpty ? 5.0 : 0.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: buildFilePreviews(),
              ),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: errorHeight,
            child: widget.uploadFileError.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Text(
                      widget.uploadFileError,
                      style: TextStyle(color: theme.errorTextColor),
                    ),
                  )
                : Container(),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> getStyleSheet(ThemeData theme) {
    return {
      'previewContainer': {
        'display': 'flex',
        'flexDirection': 'column',
      },
      'fileContainer': {
        'display': 'flex',
        'flexDirection': 'row',
        'height': 0.0,
      },
      'errorContainer': {
        'height': 0.0,
      },
      'errorTextContainer': {
        'marginTop': Platform.isIOS ? 4.0 : 2.0,
        'marginHorizontal': 12.0,
        'flex': 1,
      },
      'scrollView': {
        'flex': 1,
      },
      'scrollViewContent': {
        'alignItems': 'flex-end',
        'paddingRight': 12.0,
      },
      'warning': {
        'color': theme.errorTextColor,
        'flex': 1,
        'flexWrap': 'wrap',
      },
    };
  }
}
