import 'package:flutter/material.dart';
import 'package:mattermost_flutter/components/image_renderer.dart';
import 'package:mattermost_flutter/components/pager.dart';
import 'package:mattermost_flutter/types.dart';

class GalleryViewer extends StatefulWidget {
  final double gutterWidth;
  final double height;
  final int initialIndex;
  final List<GalleryItemType> items;
  final String Function(GalleryItemType, int)? keyExtractor;
  final int numToRender;
  final void Function(int)? onIndexChange;
  final Widget Function(ImageRendererProps, int)? renderPage;
  final double width;
  final void Function(bool)? onDoubleTap;
  final void Function(InteractionType)? onInteraction;
  final void Function()? onGesture;
  final void Function(bool)? onShouldHideControls;
  final void Function()? onTap;
  final void Function()? onPagerEnabledGesture;
  final bool Function()? shouldPagerHandleGestureEvent;

  const GalleryViewer({
    Key? key,
    this.gutterWidth = 0.0,
    required this.height,
    this.initialIndex = 0,
    required this.items,
    this.keyExtractor,
    this.numToRender = 1,
    this.onIndexChange,
    this.renderPage,
    required this.width,
    this.onDoubleTap,
    this.onInteraction,
    this.onGesture,
    this.onShouldHideControls,
    this.onTap,
    this.onPagerEnabledGesture,
    this.shouldPagerHandleGestureEvent,
  }) : super(key: key);

  @override
  _GalleryViewerState createState() => _GalleryViewerState();
}

class _GalleryViewerState extends State<GalleryViewer> {
  late bool controlsHidden;
  late int tempIndex;

  @override
  void initState() {
    super.initState();
    controlsHidden = false;
    tempIndex = widget.initialIndex;
  }

  void setTempIndex(int nextIndex) {
    setState(() {
      tempIndex = nextIndex;
    });
  }

  String extractKey(GalleryItemType item, int index) {
    if (widget.keyExtractor != null) {
      return widget.keyExtractor!(item, index);
    }
    return item.id;
  }

  void onIndexChangeWorklet(int nextIndex) {
    setTempIndex(nextIndex);

    if (widget.onIndexChange != null) {
      widget.onIndexChange!(nextIndex);
    }
  }

  Widget pageToRender(RenderPageProps pagerProps, int index) {
    void shouldHideControls([bool? isScaled]) {
      bool shouldHide = true;

      if (isScaled is bool) {
        shouldHide = !isScaled;
      } else if (isScaled is String) {
        shouldHide = true;
      } else {
        shouldHide = !controlsHidden;
      }

      setState(() {
        controlsHidden = shouldHide;
      });

      if (widget.onShouldHideControls != null) {
        widget.onShouldHideControls!(shouldHide);
      }
    }

    void doubleTap(bool isScaled) {
      if (widget.onDoubleTap != null) {
        widget.onDoubleTap!(isScaled);
      }
      shouldHideControls(isScaled);
    }

    void tap([bool? isScaled]) {
      if (widget.onTap != null) {
        widget.onTap!(isScaled ?? false);
      }
      shouldHideControls();
    }

    void interaction(InteractionType type) {
      if (widget.onInteraction != null) {
        widget.onInteraction!(type);
      }
      shouldHideControls(type);
    }

    final props = ImageRendererProps(
      width: widget.width,
      height: widget.height,
      onDoubleTap: doubleTap,
      onTap: tap,
      onInteraction: interaction,
      // other properties from pagerProps if needed
    );

    if (props.item.type != 'image' && props.item.type != 'avatar' && widget.renderPage != null) {
      return widget.renderPage!(props, index);
    }

    return ImageRenderer(props: props);
  }

  @override
  Widget build(BuildContext context) {
    return Pager(
      totalCount: widget.items.length,
      keyExtractor: extractKey,
      initialIndex: tempIndex,
      pages: widget.items,
      width: widget.width,
      height: widget.height,
      gutterWidth: widget.gutterWidth,
      onIndexChange: onIndexChangeWorklet,
      shouldHandleGestureEvent: widget.shouldPagerHandleGestureEvent,
      onGesture: widget.onGesture,
      onEnabledGesture: widget.onPagerEnabledGesture,
      renderPage: pageToRender,
      numToRender: widget.numToRender,
    );
  }
}
