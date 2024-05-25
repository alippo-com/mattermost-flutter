import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:mattermost_flutter/components/compass_icon.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/typography.dart';
import 'package:mattermost_flutter/utils/strings.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:provider/provider.dart';

class AnimatedOptionBox extends StatefulWidget {
  final String animatedBackgroundColor;
  final String animatedColor;
  final String animatedIconName;
  final String animatedText;
  final String iconName;
  final void Function()? onAnimationEnd;
  final void Function() onPress;
  final String? testID;
  final String text;

  const AnimatedOptionBox({
    required this.animatedBackgroundColor,
    required this.animatedColor,
    required this.animatedIconName,
    required this.animatedText,
    required this.iconName,
    this.onAnimationEnd,
    required this.onPress,
    this.testID,
    required this.text,
  });

  @override
  _AnimatedOptionBoxState createState() => _AnimatedOptionBoxState();
}

class _AnimatedOptionBoxState extends State<AnimatedOptionBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _backgroundColorAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;

  bool activated = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _backgroundColorAnimation = ColorTween(
      begin: Colors.transparent,
      end: Color(int.parse(widget.animatedBackgroundColor)),
    ).animate(_controller);

    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(_controller);

    _scaleAnimation = Tween<double>(
      begin: 0.25,
      end: 1.0,
    ).animate(_controller);

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onAnimationEnd?.call();
        Future.delayed(const Duration(milliseconds: 1200), () {
          setState(() {
            activated = false;
          });
          _controller.reverse();
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleOnPress() {
    setState(() {
      activated = true;
    });
    _controller.forward();
    widget.onPress.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeNotifier>(context).currentTheme;
    final styles = _getStyleSheet(theme);

    return GestureDetector(
      onTap: activated ? null : _handleOnPress,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              color: _backgroundColorAnimation.value,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Stack(
              children: [
                Opacity(
                  opacity: _opacityAnimation.value,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CompassIcon(
                          name: widget.iconName,
                          size: 24,
                          color: activated
                              ? theme.buttonBg
                              : changeOpacity(theme.centerChannelColor, 0.56),
                        ),
                        Text(
                          widget.text,
                          style: styles['text']!.copyWith(
                            color: activated
                                ? theme.buttonBg
                                : changeOpacity(theme.centerChannelColor, 0.56),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CompassIcon(
                          name: widget.animatedIconName,
                          size: 24,
                          color: Color(int.parse(widget.animatedColor)),
                        ),
                        Text(
                          widget.animatedText,
                          style: styles['text']!.copyWith(
                            color: Color(int.parse(widget.animatedColor)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Map<String, TextStyle> _getStyleSheet(ThemeData theme) {
    return {
      'text': TextStyle(
        color: changeOpacity(theme.centerChannelColor, 0.56),
        paddingHorizontal: 5,
        textTransform: 'capitalize',
        ...typography('Body', 50, 'SemiBold'),
      ),
    };
  }
}
