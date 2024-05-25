
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mattermost_flutter/utils/theme.dart'; // Assuming you have these utility functions
import 'package:mattermost_flutter/types/onboarding.dart'; // Assuming you have these types defined
import 'package:provider/provider.dart'; // For theme management

const double ONBOARDING_CONTENT_MAX_WIDTH = 520;

class SlideItem extends StatefulWidget {
  final OnboardingItem item;
  final ThemeData theme;
  final double scrollX;
  final int index;
  final int lastSlideIndex;

  const SlideItem({
    required this.item,
    required this.theme,
    required this.scrollX,
    required this.index,
    required this.lastSlideIndex,
    Key? key,
  }) : super(key: key);

  @override
  _SlideItemState createState() => _SlideItemState();
}

class _SlideItemState extends State<SlideItem> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _imageAnimation;
  late Animation<double> _titleAnimation;
  late Animation<double> _descriptionAnimation;
  bool _firstLoad = true;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _imageAnimation = Tween<double>(begin: widget.scrollX, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Interval(0.0, 0.6, curve: Curves.easeOut)),
    );

    _titleAnimation = Tween<double>(begin: widget.scrollX, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Interval(0.0, 0.8, curve: Curves.easeOut)),
    );

    _descriptionAnimation = Tween<double>(begin: widget.scrollX, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Interval(0.0, 1.0, curve: Curves.easeOut)),
    );

    if (widget.index == 0) {
      _controller.forward();
      _firstLoad = false;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeNotifier>(context).getTheme();
    final styles = _getStyleSheet(theme);

    return Container(
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _imageAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(_imageAnimation.value, 0),
                child: Opacity(
                  opacity: _firstLoad ? 0 : 1,
                  child: Container(
                    decoration: styles['image'],
                    child: widget.item.image,
                  ),
                ),
              );
            },
          ),
          AnimatedBuilder(
            animation: _titleAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(_titleAnimation.value, 0),
                child: Opacity(
                  opacity: _firstLoad ? 0 : 1,
                  child: Text(
                    widget.item.title,
                    style: widget.index == 0 ? styles['fontFirstTitle'] : styles['fontTitle'],
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            },
          ),
          AnimatedBuilder(
            animation: _descriptionAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(_descriptionAnimation.value, 0),
                child: Opacity(
                  opacity: _firstLoad ? 0 : 1,
                  child: Text(
                    widget.item.description,
                    style: styles['description'],
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getStyleSheet(ThemeData theme) {
    return {
      'image': BoxDecoration(
        color: changeOpacity(theme.centerChannelColor, 0.04),
        borderRadius: BorderRadius.circular(4),
      ),
      'fontTitle': TextStyle(
        color: theme.centerChannelColor,
        fontSize: 32,
        fontWeight: FontWeight.w600,
      ),
      'fontFirstTitle': TextStyle(
        color: theme.centerChannelColor,
        fontSize: 36,
        fontWeight: FontWeight.w600,
        paddingTop: 48,
        letterSpacing: -1,
      ),
      'description': TextStyle(
        color: changeOpacity(theme.centerChannelColor, 0.64),
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
    };
  }
}

double changeOpacity(Color color, double opacity) {
  return color.withOpacity(opacity);
}
