import 'package:flutter/material.dart';
import 'package:mattermost_flutter/constants/screens.dart';
import 'package:mattermost_flutter/utils/tap.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/types/models/servers/post.dart';
import 'package:mattermost_flutter/components/compass_icon.dart';
import 'package:mattermost_flutter/context/server.dart';

class HeaderReply extends StatelessWidget {
  final int commentCount;
  final String location;
  final PostModel post;
  final ThemeData theme;

  HeaderReply({
    required this.commentCount,
    required this.location,
    required this.post,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final style = getStyleSheet(theme);
    final serverUrl = useServerUrl(context);

    void onPress() => preventDoubleTap(() {
      final rootId = post.rootId ?? post.id;
      fetchAndSwitchToThread(serverUrl, rootId);
    });

    return Container(
      child: GestureDetector(
        onTap: onPress,
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: theme.centerChannelColor.withOpacity(0.15),
                width: 1,
              ),
              left: BorderSide(
                color: theme.linkColor.withOpacity(0.6),
                width: 3,
              ),
              right: BorderSide(
                color: theme.centerChannelColor.withOpacity(0.15),
                width: 1,
              ),
              top: BorderSide(
                color: theme.centerChannelColor.withOpacity(0.15),
                width: 1,
              ),
            ),
          ),
          margin: EdgeInsets.only(top: 5),
          padding: EdgeInsets.all(12),
          child: Row(
            children: [
              CompassIcon(
                name: 'reply-outline',
                size: 18,
                color: theme.linkColor,
              ),
              if (location != SEARCH && commentCount > 0)
                Text(
                  '$commentCount',
                  style: style.replyText,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> getStyleSheet(ThemeData theme) {
    return {
      'replyWrapper': {
        'flex': 1,
        'justifyContent': 'flex-end',
      },
      'replyIconContainer': {
        'flexDirection': 'row',
        'alignItems': 'flex-start',
        'justifyContent': 'flex-end',
        'minWidth': 40,
        'paddingTop': 2,
        'flex': 1,
      },
      'replyText': {
        'fontSize': 12,
        'marginLeft': 2,
        'marginTop': 2,
        'color': theme.linkColor,
      },
    };
  }

  ThemeData useTheme(BuildContext context) {
    return Theme.of(context);
  }
}
