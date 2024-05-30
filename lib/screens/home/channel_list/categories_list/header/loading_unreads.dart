import 'package:flutter/material.dart';
import 'package:mattermost_flutter/context/server.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/utils/theme.dart';

class LoadingUnreads extends StatefulWidget {
  @override
  _LoadingUnreadsState createState() => _LoadingUnreadsState();
}

class _LoadingUnreadsState extends State<LoadingUnreads> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  late Animation<double> _opacityAnimation;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    final serverUrl = useServerUrl();
    loading = useTeamsLoading(serverUrl);

    _controller = AnimationController(
      duration: const Duration(milliseconds: 750),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(begin: 0, end: 360).animate(_controller)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _controller.repeat();
        }
      });

    _opacityAnimation = Tween<double>(begin: 1, end: 0).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.ease,
    ));

    if (loading) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(LoadingUnreads oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (loading) {
      _controller.repeat();
    } else {
      _controller.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = useTheme();
    final style = getStyleSheet(theme);

    if (!loading) {
      return Container();
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value,
            child: Container(
              height: 14,
              width: 14,
              margin: EdgeInsets.only(left: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(7),
                border: Border.all(
                  color: changeOpacity(theme.sidebarText, 0.16),
                  width: 2,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  BoxDecoration getStyleSheet(Theme theme) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(7),
      border: Border.all(
        color: changeOpacity(theme.sidebarText, 0.16),
        width: 2,
      ),
    );
  }
}
