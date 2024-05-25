import 'package:flutter/material.dart';
import 'image_transformer.dart';

class ImageRenderer extends StatelessWidget {
  final double height;
  final bool isPageActive;
  final bool isPagerInProgress;
  final dynamic item;
  final Function()? onDoubleTap;
  final Function()? onInteraction;
  final Function()? onPageStateChange;
  final Function()? onTap;
  final List<dynamic>? pagerRefs;
  final double width;

  ImageRenderer({
    required this.height,
    required this.isPageActive,
    required this.isPagerInProgress,
    required this.item,
    this.onDoubleTap,
    this.onInteraction,
    this.onPageStateChange,
    this.onTap,
    this.pagerRefs,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    final targetDimensions = {'height': height, 'width': width};

    return ImageTransformer(
      outerGestureHandlerActive: isPagerInProgress,
      isActive: isPageActive,
      targetDimensions: targetDimensions,
      height: item['height'],
      isSvg: item['extension'] == 'svg',
      onStateChange: onPageStateChange,
      outerGestureHandlerRefs: pagerRefs,
      source: item['uri'],
      width: item['width'],
      onDoubleTap: onDoubleTap,
      onTap: onTap,
      onInteraction: onInteraction,
    );
  }
}
