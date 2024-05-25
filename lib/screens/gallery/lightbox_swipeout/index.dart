import 'package:flutter/material.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/physics.dart';

// Define required custom classes and utilities
class BackdropProps {
  final AnimatedBuilder animatedStyles;
  final ValueNotifier<double> translateY;

  BackdropProps({required this.animatedStyles, required this.translateY});
}

class GalleryItemType {
  final String type;
  final double height;
  final double width;

  GalleryItemType({required this.type, required this.height, required this.width});
}

class GalleryManagerSharedValues {
  final ValueNotifier<double> x;
  final ValueNotifier<double> y;
  final ValueNotifier<double> width;
  final ValueNotifier<double> height;
  final ValueNotifier<double> opacity;
  final ValueNotifier<double> targetWidth;
  final ValueNotifier<double> targetHeight;

  GalleryManagerSharedValues({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.opacity,
    required this.targetWidth,
    required this.targetHeight,
  });
}

class LightboxSwipeout extends StatefulWidget {
  final Widget Function({
    required Function(PointerEvent) onGesture,
    required bool Function() shouldHandleEvent,
  }) children;
  final VoidCallback onAnimationFinished;
  final Function(double) onSwipeActive;
  final VoidCallback onSwipeFailure;
  final Widget Function(BackdropProps)? renderBackdropComponent;
  final Widget Function({
    required ImageProvider imageProvider,
    required double width,
    required double height,
    required BoxDecoration itemStyles,
  })? renderItem;
  final String source;
  final GalleryItemType target;
  final Size targetDimensions;
  final GalleryManagerSharedValues sharedValues;

  LightboxSwipeout({
    required this.children,
    required this.onAnimationFinished,
    required this.onSwipeActive,
    required this.onSwipeFailure,
    this.renderBackdropComponent,
    this.renderItem,
    required this.source,
    required this.target,
    required this.targetDimensions,
    required this.sharedValues,
  });

  @override
  _LightboxSwipeoutState createState() => _LightboxSwipeoutState();
}

class _LightboxSwipeoutState extends State<LightboxSwipeout>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _renderChildren = false;
  late ValueNotifier<double> _translateY;
  late ValueNotifier<double> _childTranslateY;
  late ValueNotifier<double> _lightboxImageOpacity;
  late ValueNotifier<double> _childrenOpacity;

  @override
  void initState() {
    super.initState();
    _translateY = ValueNotifier(0);
    _childTranslateY = ValueNotifier(0);
    _lightboxImageOpacity = ValueNotifier(1);
    _childrenOpacity = ValueNotifier(0);

    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    )..addListener(() {
        setState(() {});
      });

    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _translateY.dispose();
    _childTranslateY.dispose();
    _lightboxImageOpacity.dispose();
    _childrenOpacity.dispose();
    super.dispose();
  }

  void closeLightbox() {
    _lightboxImageOpacity.value = 1;
    _childrenOpacity.value = 0;
    _controller.reverse().then((_) {
      widget.sharedValues.opacity.value = 1;
      widget.onAnimationFinished();
    });
  }

  bool shouldHandleEvent() {
    return _childTranslateY.value == 0;
  }

  bool isVisibleImage() {
    return widget.targetDimensions.height >= widget.sharedValues.y.value &&
        widget.targetDimensions.width >= widget.sharedValues.x.value &&
        widget.sharedValues.x.value >= 0 &&
        widget.sharedValues.y.value >= 0;
  }

  @override
  Widget build(BuildContext context) {
    final imageProvider = NetworkImage(widget.source);
    final itemStyles = BoxDecoration(
      image: DecorationImage(
        image: imageProvider,
        fit: BoxFit.cover,
      ),
      borderRadius: BorderRadius.circular(18),
    );

    return GestureDetector(
      onPanUpdate: (details) {
        _childTranslateY.value = details.delta.dy;
        widget.onSwipeActive(_childTranslateY.value);
      },
      onPanEnd: (details) {
        if (details.velocity.pixelsPerSecond.dy > 0) {
          final elementVisible = isVisibleImage();
          if (elementVisible) {
            closeLightbox();
          } else {
            _childTranslateY.value = widget.target.height * 2;
            widget.onAnimationFinished();
          }
        } else {
          _lightboxImageOpacity.value = 0;
          _childrenOpacity.value = 1;
          _childTranslateY.value = 0;
          widget.onSwipeFailure();
        }
      },
      child: Stack(
        children: [
          if (widget.renderBackdropComponent != null)
            widget.renderBackdropComponent!(
              BackdropProps(
                animatedStyles: AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return Container(
                      color: Colors.black.withOpacity(_animation.value),
                    );
                  },
                ),
                translateY: _childTranslateY,
              ),
            ),
          if (widget.renderItem != null)
            Positioned.fill(
              child: widget.renderItem!(
                imageProvider: imageProvider,
                width: widget.targetDimensions.width,
                height: widget.targetDimensions.height,
                itemStyles: itemStyles,
              ),
            )
          else
            Positioned.fill(
              child: Container(
                decoration: itemStyles,
              ),
            ),
          if (_renderChildren)
            Positioned.fill(
              child: widget.children(
                onGesture: (event) {},
                shouldHandleEvent: shouldHandleEvent,
              ),
            ),
        ],
      ),
    );
  }
}
