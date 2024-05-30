
import 'package:flutter/material.dart';
import 'package:mattermost_flutter/utils/images.dart';
import 'package:mattermost_flutter/components/files_search/file_options/tablet_options.dart';
import 'package:mattermost_flutter/types.dart'; // Assuming GalleryAction is defined here

typedef XyOffset = Offset?;

class FileResult extends StatefulWidget {
  final bool canDownloadFiles;
  final String? channelName;
  final FileInfo fileInfo;
  final int index;
  final int numOptions;
  final Function(FileInfo) onOptionsPress;
  final Function(int) onPress;
  final bool publicLinkEnabled;
  final Function(GalleryAction) setAction;
  final Function(int, FileInfo) updateFileForGallery;

  const FileResult({
    required this.canDownloadFiles,
    this.channelName,
    required this.fileInfo,
    required this.index,
    required this.numOptions,
    required this.onOptionsPress,
    required this.onPress,
    required this.publicLinkEnabled,
    required this.setAction,
    required this.updateFileForGallery,
  });

  @override
  _FileResultState createState() => _FileResultState();
}

class _FileResultState extends State<FileResult> {
  final elementsRef = GlobalKey();
  bool showOptions = false;
  bool openUp = false;
  XyOffset? xyOffset;
  late double height;

  @override
  void initState() {
    super.initState();
    height = MediaQuery.of(context).size.height;
  }

  void handleOptionsPress(FileInfo fileInfo) {
    setState(() {
      showOptions = true;
    });
    widget.onOptionsPress(fileInfo);
  }

  void handleSetAction(GalleryAction action) {
    widget.setAction(action);
    if (showOptions && action != 'none') {
      setState(() {
        showOptions = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = useIsTablet();
    final isReplyPost = false;

    return Stack(
      children: [
        Container(
          key: elementsRef,
          margin: EdgeInsets.symmetric(horizontal: 20),
          child: File(
            asCard: true,
            canDownloadFiles: widget.canDownloadFiles,
            channelName: widget.channelName,
            file: widget.fileInfo,
            galleryIdentifier: 'search-files-location',
            inViewPort: true,
            index: widget.index,
            nonVisibleImagesCount: 0,
            onOptionsPress: handleOptionsPress,
            onPress: widget.onPress,
            optionSelected: isTablet && showOptions,
            publicLinkEnabled: widget.publicLinkEnabled,
            showDate: true,
            updateFileForGallery: widget.updateFileForGallery,
            wrapperWidth: getViewPortWidth(isReplyPost, isTablet) - 6,
          ),
        ),
        if (isTablet && showOptions && xyOffset != null)
          TabletOptions(
            fileInfo: widget.fileInfo,
            numOptions: widget.numOptions,
            openUp: openUp,
            setAction: handleSetAction,
            setShowOptions: (bool value) {
              setState(() {
                showOptions = value;
              });
            },
            xyOffset: xyOffset,
          ),
      ],
    );
  }
}
