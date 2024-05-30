// Converted from React Native to Flutter

import 'package:flutter/material.dart';
import 'package:mattermost_flutter/calls/context.dart';
import 'package:mattermost_flutter/calls/utils.dart';
import 'package:mattermost_flutter/utils/gallery.dart';
import 'footer.dart';
import 'header.dart';
import 'package:mattermost_flutter/types/screens/gallery.dart';
import 'package:mattermost_flutter/types/screens/navigation.dart';

class GalleryScreen extends StatefulWidget {
  final AvailableScreens componentId;
  final String galleryIdentifier;
  final bool hideActions;
  final int initialIndex;
  final List<GalleryItemType> items;

  GalleryScreen({
    required this.componentId,
    required this.galleryIdentifier,
    required this.hideActions,
    required this.initialIndex,
    required this.items,
  });

  @override
  _GalleryScreenState createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  late Size dimensions;
  late bool isTablet;
  late int localIndex;
  late List<bool> captionsEnabled;
  late List<bool> captionsAvailable;
  late GalleryControls galleryControls;
  final galleryRef = GlobalKey<GalleryState>();

  @override
  void initState() {
    super.initState();
    isTablet = useIsTablet();
    localIndex = widget.initialIndex;
    captionsEnabled = List<bool>.filled(widget.items.length, true);
    captionsAvailable = widget.items.map((item) => hasCaptions(item.postProps)).toList();
    galleryControls = useGalleryControls();
    dimensions = Size(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height);
    useAndroidHardwareBackHandler(widget.componentId, close);
  }

  void onCaptionsPressIdx(int idx) {
    setState(() {
      captionsEnabled[idx] = !captionsEnabled[idx];
    });
  }

  void onCaptionsPress() {
    onCaptionsPressIdx(localIndex);
  }

  void onClose() {
    freezeOtherScreens(false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      galleryRef.currentState?.close();
    });
  }

  void close() {
    setScreensOrientation(isTablet);
    if (Platform.isIOS && !isTablet) {
      // We need both the navigation & the module
      NativeModules.splitView.lockPortrait();
    }
    freezeOtherScreens(false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      dismissOverlay(widget.componentId);
    });
  }

  void onIndexChange(int index) {
    setState(() {
      localIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CaptionsEnabledContext(
      value: captionsEnabled,
      child: Column(
        children: [
          Header(
            index: localIndex,
            onClose: onClose,
            style: galleryControls.headerStyles,
            total: widget.items.length,
          ),
          Gallery(
            galleryIdentifier: widget.galleryIdentifier,
            initialIndex: widget.initialIndex,
            items: widget.items,
            onHide: close,
            onIndexChange: onIndexChange,
            onShouldHideControls: galleryControls.setControlsHidden,
            key: galleryRef,
            targetDimensions: dimensions,
          ),
          Footer(
            hideActions: widget.hideActions,
            item: widget.items[localIndex],
            style: galleryControls.footerStyles,
            hasCaptions: captionsAvailable[localIndex],
            captionEnabled: captionsEnabled[localIndex],
            onCaptionsPress: onCaptionsPress,
          ),
        ],
      ),
    );
  }
}
