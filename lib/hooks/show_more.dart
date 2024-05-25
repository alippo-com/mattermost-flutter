import 'package:flutter/animation.dart';
import 'package:flutter/widgets.dart';

class ShowMoreController {
  AnimationController? controller;
  Animation<double>? animation;

  ShowMoreController(TickerProvider vsync, {double height = 0, double maxHeight = 0, bool open = false}) {
    controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: vsync,
    );
    animation = Tween<double>(begin: open ? height : maxHeight, end: open ? maxHeight : height).animate(
      CurvedAnimation(
        parent: controller!,
        curve: Curves.linear,
      ),
    );
    if (open) {
      controller!.forward();
    } else {
      controller!.reverse();
    }
  }

  AnimatedBuilder useShowMoreAnimatedStyle() {
    return AnimatedBuilder(
      animation: controller!,
      builder: (context, child) {
        return Container(
          constraints: BoxConstraints(maxHeight: animation!.value),
        );
      },
    );
  }
}
