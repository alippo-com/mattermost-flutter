import 'package:flutter/material.dart';
import 'package:mattermost_flutter/components/formatted_text.dart';
import 'package:mattermost_flutter/context/server.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/i18n.dart';
import 'package:mattermost_flutter/utils/tap.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/typography.dart';

class ThreadFollow extends StatefulWidget {
  final bool isFollowing;
  final String teamId;
  final String threadId;

  const ThreadFollow({
    required this.isFollowing,
    required this.teamId,
    required this.threadId,
  });

  @override
  _ThreadFollowState createState() => _ThreadFollowState();
}

class _ThreadFollowState extends State<ThreadFollow> {
  late String serverUrl;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    serverUrl = useServerUrl(context);
  }

  void onPress() {
    preventDoubleTap(() {
      updateThreadFollowing(
        serverUrl,
        widget.teamId,
        widget.threadId,
        !widget.isFollowing,
        false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.threadId.isEmpty) {
      return Container();
    }

    final theme = useTheme(context);
    final styles = _getStyleSheet(theme);

    final containerStyle = [styles.container];
    Map<String, String> followTextProps = {
      'id': t('threads.follow'),
      'defaultMessage': 'Follow',
    };
    if (widget.isFollowing) {
      containerStyle.add(styles.containerActive);
      followTextProps = {
        'id': t('threads.following'),
        'defaultMessage': 'Following',
      };
    }

    final followThreadButtonTestId =
        widget.isFollowing ? 'thread.following_thread.button' : 'thread.follow_thread.button';

    return GestureDetector(
      onTap: onPress,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: theme.sidebarHeaderTextColor),
          borderRadius: BorderRadius.circular(4),
          color: widget.isFollowing
              ? changeOpacity(theme.sidebarHeaderTextColor, 0.24)
              : Colors.transparent,
        ),
        padding: EdgeInsets.symmetric(vertical: 4.5, horizontal: 10),
        child: FormattedText(
          id: followTextProps['id']!,
          defaultMessage: followTextProps['defaultMessage']!,
          style: TextStyle(
            color: theme.sidebarHeaderTextColor,
            fontSize: 75,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  _getStyleSheet(ThemeData theme) {
    return {
      'container': BoxDecoration(
        border: Border.all(color: theme.sidebarHeaderTextColor),
        borderRadius: BorderRadius.circular(4),
        padding: EdgeInsets.symmetric(vertical: 4.5, horizontal: 10),
        color: Colors.transparent,
      ),
      'containerActive': BoxDecoration(
        color: changeOpacity(theme.sidebarHeaderTextColor, 0.24),
        border: Border.all(color: Colors.transparent),
      ),
    };
  }
}
