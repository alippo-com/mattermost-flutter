import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/animation.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:some_package/some_package.dart'; // Placeholder for custom hooks & utils

class PagerReusableProps {
  final double? gutterWidth;
  final double? initialDiffValue;
  final int? numToRender;
  final Function(PointerEvent, ValueNotifier<bool>)? onGesture;
  final Function(PointerEvent)? onEnabledGesture;
  final Function(int)? onIndexChange;
  final Widget Function(RenderPageProps, int)? renderPage;

  PagerReusableProps({
    this.gutterWidth,
    this.initialDiffValue,
    this.numToRender,
    this.onGesture,
    this.onEnabledGesture,
    this.onIndexChange,
    this.renderPage,
  });
}

class PagerProps extends PagerReusableProps {
  final int initialIndex;
  final String Function(GalleryItemType, int) keyExtractor;
  final List<GalleryItemType> pages;
  final Function(PointerEvent)? shouldHandleGestureEvent;
  final bool shouldRenderGutter;
  final int totalCount;
  final double width;
  final double height;

  PagerProps({
    required this.initialIndex,
    required this.keyExtractor,
    required this.pages,
    required this.totalCount,
    required this.width,
    required this.height,
    this.shouldHandleGestureEvent,
    this.shouldRenderGutter = true,
    double? gutterWidth,
    double? initialDiffValue,
    int? numToRender,
    Function(PointerEvent, ValueNotifier<bool>)? onGesture,
    Function(PointerEvent)? onEnabledGesture,
    Function(int)? onIndexChange,
    Widget Function(RenderPageProps, int)? renderPage,
  }) : super(
          gutterWidth: gutterWidth,
          initialDiffValue: initialDiffValue,
          numToRender: numToRender,
          onGesture: onGesture,
          onEnabledGesture: onEnabledGesture,
          onIndexChange: onIndexChange,
          renderPage: renderPage,
        );
}

class Pager extends StatefulWidget {
  final PagerProps props;

  const Pager({Key? key, required this.props}) : super(key: key);

  @override
  _PagerState createState() => _PagerState();
}

class _PagerState extends State<Pager> with SingleTickerProviderStateMixin {
  late ValueNotifier<double> sharedWidth;
  late ValueNotifier<int> activeIndex;
  late AnimationController _controller;
  bool isActive = true;
  late ValueNotifier<double> pagerX;
  late ValueNotifier<double> offsetX;
  late ValueNotifier<double> toValueAnimation;
  late ValueNotifier<double> velocity;

  @override
  void initState() {
    super.initState();

    sharedWidth = ValueNotifier(widget.props.width);
    activeIndex = ValueNotifier(widget.props.initialIndex);
    pagerX = ValueNotifier(0);
    offsetX = ValueNotifier(_getPageTranslate(widget.props.initialIndex));
    toValueAnimation = ValueNotifier(_getPageTranslate(widget.props.initialIndex));
    velocity = ValueNotifier(0);

    _controller = AnimationController(
      duration: Duration(milliseconds: 250),
      vsync: this,
    )..addListener(() {
        setState(() {});
      });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    sharedWidth.dispose();
    activeIndex.dispose();
    pagerX.dispose();
    offsetX.dispose();
    toValueAnimation.dispose();
    velocity.dispose();
    super.dispose();
  }

  double _getPageTranslate(int i) {
    final t = i * sharedWidth.value;
    final g = (widget.props.shouldRenderGutter ? widget.props.gutterWidth ?? 0 : 0) * i;
    return -(t + g);
  }

  void _onIndexChange(int nextIndex) {
    setState(() {
      activeIndex.value = nextIndex;
    });
    widget.props.onIndexChange?.call(nextIndex);
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      pagerX.value = details.delta.dx;
    });
    widget.props.onGesture?.call(PointerEvent.fromDragUpdateDetails(details), ValueNotifier(isActive));
  }

  void _onPanEnd(DragEndDetails details) {
    // Handle the end of the pan gesture
  }

  @override
  Widget build(BuildContext context) {
    final totalWidth = (widget.props.totalCount * widget.props.width) + ((widget.props.gutterWidth ?? 0) * widget.props.totalCount - 2);

    return GestureDetector(
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: Stack(
        children: [
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(pagerX.value + offsetX.value, 0),
                  child: SizedBox(
                    width: totalWidth,
                    child: Row(
                      children: widget.props.pages.map((page) {
                        return widget.props.renderPage!(RenderPageProps(page: page), activeIndex.value);
                      }).toList(),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
``