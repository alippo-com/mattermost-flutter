import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/animation.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:animated_widgets/animated_widgets.dart';
import 'package:vector_math/vector_math_64.dart' as vec;

class ImageTransformer extends StatefulWidget {
  final bool enabled;
  final double height;
  final bool isSvg;
  final String source;
  final Map<String, double> targetDimensions;
  final double width;
  final Function(bool)? onDoubleTap;
  final Function(String)? onInteraction;
  final Function(bool)? onTap;
  final Function(bool)? onStateChange;
  final List<GlobalKey>? outerGestureHandlerRefs;
  final AnimatedSharedValue? isActive;
  final AnimatedSharedValue? outerGestureHandlerActive;

  const ImageTransformer({
    Key? key,
    this.enabled = true,
    required this.height,
    required this.isSvg,
    required this.source,
    required this.targetDimensions,
    required this.width,
    this.onDoubleTap,
    this.onInteraction,
    this.onTap,
    this.onStateChange,
    this.outerGestureHandlerRefs,
    this.isActive,
    this.outerGestureHandlerActive,
  }) : super(key: key);

  @override
  _ImageTransformerState createState() => _ImageTransformerState();
}

class _ImageTransformerState extends State<ImageTransformer> with SingleTickerProviderStateMixin {
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
      duration: Duration(milliseconds: 250),
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
      widget.onStateChange?.call(true);
    });
  }

  bool shouldHandleEvent() {
    return _childTranslateY.value == 0;
  }

  bool isVisibleImage() {
    return widget.targetDimensions['height']! >= widget.height &&
        widget.targetDimensions['width']! >= widget.width;
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
        widget.onInteraction?.call('pan');
      },
      onPanEnd: (details) {
        if (details.velocity.pixelsPerSecond.dy > 0) {
          final elementVisible = isVisibleImage();
          if (elementVisible) {
            closeLightbox();
          } else {
            _childTranslateY.value = widget.height * 2;
            widget.onStateChange?.call(true);
          }
        } else {
          _lightboxImageOpacity.value = 0;
          _childrenOpacity.value = 1;
          _childTranslateY.value = 0;
          widget.onStateChange?.call(false);
        }
      },
      child: Stack(
        children: [
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
