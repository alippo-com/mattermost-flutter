import 'package:flutter/widgets.dart';

class UseShowMoreAnimatedStyle {
  final AnimationController controller;
  final Animation<double> animation;

  UseShowMoreAnimatedStyle({
    required TickerProvider vsync,
    double? height,
    required double maxHeight,
    required bool open,
  }) : controller = AnimationController(
         duration: const Duration(milliseconds: 300),
         vsync: vsync,
       ),
       animation = Tween<double>(
         begin: open ? height : maxHeight,
         end: open ? maxHeight : height,
       ).animate(CurvedAnimation(
         parent: controller,
         curve: Curves.linear,
       )) {
         if (!open) {
           controller.forward();
         } else {
           controller.reverse();
         }
       }

  Widget animatedBuilder(Widget Function(BuildContext, Widget?) builder) {
    return AnimatedBuilder(
      animation: controller,
      builder: builder,
    );
  }
}