import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';
import 'package:mattermost_flutter/components/document_renderer.dart';
import 'package:mattermost_flutter/components/video_renderer.dart';
import 'package:mattermost_flutter/components/gallery_viewer.dart';
import 'package:mattermost_flutter/components/lightbox_swipeout.dart';
import 'package:mattermost_flutter/components/backdrop.dart';
import 'package:mattermost_flutter/context/gallery.dart';
import 'package:mattermost_flutter/utils/gallery.dart';
import 'package:mattermost_flutter/types/screens/gallery.dart';
import 'package:reactive_forms/reactive_forms.dart'; // Assuming a package for form management

class GalleryScreen extends StatefulWidget {
  final String galleryIdentifier;
  final int initialIndex;
  final List<GalleryItemType> items;
  final void Function(int)? onIndexChange;
  final VoidCallback onHide;
  final Size targetDimensions;
  final void Function(bool) onShouldHideControls;

  GalleryScreen({
    required this.galleryIdentifier,
    required this.initialIndex,
    required this.items,
    this.onIndexChange,
    required this.onHide,
    required this.targetDimensions,
    required this.onShouldHideControls,
  });

  @override
  _GalleryScreenState createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  late int localIndex;
  late LightboxSwipeoutRef lightboxRef;
  late GalleryContext galleryContext;

  @override
  void initState() {
    super.initState();
    localIndex = widget.initialIndex;
    lightboxRef = LightboxSwipeoutRef();
    galleryContext = Provider.of<GalleryContext>(context, listen: false);
    galleryContext.setGalleryIdentifier(widget.galleryIdentifier);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateTargetDimensions();
    });
  }

  void _updateTargetDimensions() {
    final item = widget.items[localIndex];
    final scaleFactor = item.width / widget.targetDimensions.width;
    final th = item.height / scaleFactor;
    galleryContext.setTargetDimensions(widget.targetDimensions.width, th);
  }

  @override
  void dispose() {
    super.dispose();
  }

  void close() {
    lightboxRef.closeLightbox();
  }

  void onLocalIndex(int index) {
    setState(() {
      localIndex = index;
    });
    widget.onIndexChange?.call(index);
  }

  void onSwipeActive(double translateY) {
    if (translateY.abs() > 8) {
      widget.onShouldHideControls(true);
    }
  }

  void onSwipeFailure() {
    galleryContext.freezeOtherScreens(true);
    widget.onShouldHideControls(false);
  }

  void hideLightboxItem() {
    galleryContext.hideLightboxItem();
    widget.onHide();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.items[localIndex];

    return LightboxSwipeout(
      ref: lightboxRef,
      target: item,
      onAnimationFinished: hideLightboxItem,
      sharedValues: galleryContext.sharedValues,
      source: item.uri,
      onSwipeActive: onSwipeActive,
      onSwipeFailure: onSwipeFailure,
      renderBackdropComponent: (animatedStyles, translateY) {
        return Backdrop(
          animatedStyles: animatedStyles,
          translateY: translateY,
        );
      },
      targetDimensions: widget.targetDimensions,
      renderItem: (info) {
        if (item.type == 'video' && item.posterUri != null) {
          return AnimatedImage(
            source: item.posterUri!,
            style: info.itemStyles as AnimatedStyle<ImageStyle>,
          );
        }
        return null;
      },
      child: (onGesture, shouldHandleEvent) {
        return GalleryViewer(
          items: widget.items,
          onIndexChange: onLocalIndex,
          shouldPagerHandleGestureEvent: shouldHandleEvent,
          onShouldHideControls: widget.onShouldHideControls,
          height: widget.targetDimensions.height,
          width: widget.targetDimensions.width,
          initialIndex: widget.initialIndex,
          onPagerEnabledGesture: onGesture,
          numToRender: 1,
          renderPage: (props, idx) {
            switch (props.item.type) {
              case 'video':
                return VideoRenderer(
                  item: props.item,
                  index: idx,
                  initialIndex: widget.initialIndex,
                  onShouldHideControls: widget.onShouldHideControls,
                );
              case 'file':
                return DocumentRenderer(
                  item: props.item,
                  onShouldHideControls: widget.onShouldHideControls,
                );
              default:
                return Container();
            }
          },
        );
      },
    );
  }
}
