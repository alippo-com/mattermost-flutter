import 'package:flutter/material.dart';
import 'package:flutter/animation.dart';
import 'package:mattermost_flutter/types/style_prop.dart'; // Ensure correct path for types

class AnimatedNumber extends StatefulWidget {
  final int animateToNumber;
  final TextStyle? fontStyle;
  final int? animationDuration;
  final Curve easing;

  AnimatedNumber({
    required this.animateToNumber,
    this.fontStyle,
    this.animationDuration,
    this.easing = Curves.elasticOut,
  });

  @override
  _AnimatedNumberState createState() => _AnimatedNumberState();
}

class _AnimatedNumberState extends State<AnimatedNumber> with SingleTickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;
  final List<int> NUMBERS = List.generate(10, (index) => index);
  late int _numberHeight;

  @override
  void initState() {
    super.initState();
    _numberHeight = 0;
    _controllers = [];
    _animations = [];
    _initializeAnimations();
  }

  void _initializeAnimations() {
    String animateToNumberString = widget.animateToNumber.abs().toString();
    String prevNumberString = widget.animateToNumber.abs().toString();

    List<int> numberStringToDigitsArray = animateToNumberString.split('').map(int.parse).toList();
    List<int> prevNumberersArr = prevNumberString.split('').map(int.parse).toList();

    for (int i = 0; i < numberStringToDigitsArray.length; i++) {
      AnimationController controller = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: widget.animationDuration ?? 1400),
      );
      _controllers.add(controller);

      Animation<double> animation = Tween<double>(
        begin: 0.0,
        end: -1.0 * (_numberHeight * (prevNumberersArr[i] ?? 0)),
      ).animate(CurvedAnimation(
        parent: controller,
        curve: widget.easing,
      ));
      _animations.add(animation);
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (_numberHeight == 0) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {
              _numberHeight = constraints.maxHeight.toInt();
              _initializeAnimations();
            });
          });
        }

        return Row(
          children: [
            if (widget.animateToNumber < 0)
              Text(
                '-',
                style: widget.fontStyle,
              ),
            ..._buildAnimatedNumbers(),
          ],
        );
      },
    );
  }

  List<Widget> _buildAnimatedNumbers() {
    String animateToNumberString = widget.animateToNumber.abs().toString();
    List<int> numberStringToDigitsArray = animateToNumberString.split('').map(int.parse).toList();

    return numberStringToDigitsArray.map((n) {
      int index = numberStringToDigitsArray.indexOf(n);
      return Container(
        height: _numberHeight.toDouble(),
        child: AnimatedBuilder(
          animation: _animations[index],
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _animations[index].value),
              child: Column(
                children: NUMBERS.map((number) {
                  return Text(
                    number.toString(),
                    style: widget.fontStyle,
                  );
                }).toList(),
              ),
            );
          },
        ),
      );
    }).toList();
  }
}
