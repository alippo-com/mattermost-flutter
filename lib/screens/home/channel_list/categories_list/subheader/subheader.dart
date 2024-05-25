
import 'package:flutter/material.dart';
import 'package:mattermost_flutter/types.dart'; // Assuming the types are defined here
import 'package:mattermost_flutter/constants/view.dart'; // Assuming HOME_PADDING is defined here
import 'package:mattermost_flutter/components/search_field.dart'; // Assuming SearchField component is defined here
import 'package:mattermost_flutter/components/unread_filter.dart'; // Assuming UnreadFilter component is defined here

class SubHeader extends StatefulWidget {
  final bool unreadsOnTop;

  SubHeader({required this.unreadsOnTop});

  @override
  _SubHeaderState createState() => _SubHeaderState();
}

class _SubHeaderState extends State<SubHeader> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _marginRight;
  late Animation<double> _width;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _initializeAnimation();
    if (!widget.unreadsOnTop) {
      _controller.forward();
    }
  }

  void _initializeAnimation() {
    _marginRight = Tween<double>(begin: 0, end: 8).animate(_controller);
    _width = Tween<double>(begin: 0, end: 40).animate(_controller);
    _opacity = Tween<double>(begin: 0, end: 1).animate(_controller);
  }

  @override
  void didUpdateWidget(SubHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.unreadsOnTop != widget.unreadsOnTop) {
      if (widget.unreadsOnTop) {
        _controller.reverse();
      } else {
        _controller.forward();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: HOME_PADDING,
      child: Row(
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Container(
                margin: EdgeInsets.only(right: _marginRight.value),
                width: _width.value,
                opacity: _opacity.value,
                child: UnreadFilter(),
              );
            },
          ),
          SearchField(),
        ],
      ),
    );
  }
}
