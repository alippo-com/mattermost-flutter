import 'package:flutter/material.dart';
import 'package:mattermost_flutter/types/theme.dart';
import 'package:mattermost_flutter/utils/theme.dart';

class UnreadDot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      children: [
        Positioned(
          left: 21,
          bottom: 9,
          child: Container(
            key: Key('post_unread_dot.badge'),
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: theme.sidebarTextActiveBorder,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ],
    );
  }
}
