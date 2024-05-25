// Converted from React Native to Flutter

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mattermost_flutter/components/files/file_icon.dart';
import 'package:mattermost_flutter/constants.dart';
import 'package:mattermost_flutter/utils/button_styles.dart';
import 'package:mattermost_flutter/utils/file.dart';
import 'package:mattermost_flutter/utils/gallery.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/typography.dart';
import 'package:mattermost_flutter/screens/gallery/footer/download_with_action.dart';
import 'package:mattermost_flutter/types/screens/gallery.dart';

class DocumentRenderer extends StatefulWidget {
  final bool canDownloadFiles;
  final GalleryItemType item;
  final ValueChanged<bool> onShouldHideControls;

  DocumentRenderer({
    required this.canDownloadFiles,
    required this.item,
    required this.onShouldHideControls,
  });

  @override
  _DocumentRendererState createState() => _DocumentRendererState();
}

class _DocumentRendererState extends State<DocumentRenderer> {
  late bool controls;
  late bool enabled;
  late bool isSupported;
  late String optionText;

  @override
  void initState() {
    super.initState();
    controls = true;
    enabled = true;
    isSupported = isDocument(widget.item);
    optionText = isSupported
        ? "Open file"
        : "Preview isn't supported for this file type. Try downloading or sharing to open it in another app.";
  }

  void handleHideControls() {
    widget.onShouldHideControls(controls);
    setState(() {
      controls = !controls;
    });
  }

  void setGalleryAction(GalleryAction action) {
    SystemChannels.platform.invokeMethod('HapticFeedback.vibrate');
    if (action == GalleryAction.none) {
      setState(() {
        enabled = true;
      });
    }
  }

  void handleOpenFile() {
    setState(() {
      enabled = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final file = galleryItemToFileInfo(widget.item);
    return GestureDetector(
      onTap: handleHideControls,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: Colors.transparent,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FileIcon(
                backgroundColor: Colors.transparent,
                file: file,
                iconSize: 120,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 25.0),
                child: Text(
                  widget.item.name,
                  style: typography('Body', 200, FontWeight.w600).copyWith(color: Colors.white),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                ),
              ),
              if (!isSupported)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Text(
                    optionText,
                    style: typography('Body', 100, FontWeight.w600).copyWith(color: Colors.white.withOpacity(0.64)),
                    textAlign: TextAlign.center,
                  ),
                ),
              if (isSupported && widget.canDownloadFiles)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: InkWell(
                    onTap: enabled ? handleOpenFile : null,
                    child: Container(
                      decoration: buttonBackgroundStyle(Preferences.THEMES['onyx'], 'lg', 'primary', enabled ? 'default' : 'disabled'),
                      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
                      child: Text(
                        optionText,
                        style: buttonTextStyle(Preferences.THEMES['onyx'], 'lg', 'primary', enabled ? 'default' : 'disabled'),
                      ),
                    ),
                  ),
                ),
              if (!enabled)
                DownloadWithAction(
                  action: 'opening',
                  setAction: setGalleryAction,
                  item: widget.item,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
