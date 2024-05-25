import 'package:flutter/material.dart';
import 'package:mattermost_flutter/actions/local/channel.dart';
import 'package:mattermost_flutter/components/compass_icon.dart';
import 'package:mattermost_flutter/context/server.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/utils/theme.dart';

class UnreadFilter extends StatelessWidget {
  final bool onlyUnreads;

  UnreadFilter({required this.onlyUnreads});

  @override
  Widget build(BuildContext context) {
    final theme = useTheme(context);
    final serverUrl = useServerUrl(context);
    final styles = getStyleSheet(theme);

    void onPress() {
      showUnreadChannelsOnly(serverUrl, !onlyUnreads);
    }

    return GestureDetector(
      onTap: onPress,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: onlyUnreads ? theme.sidebarText : changeOpacity(theme.sidebarText, 0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        height: 40,
        width: 40,
        margin: EdgeInsets.symmetric(vertical: 20),
        child: CompassIcon(
          color: changeOpacity(onlyUnreads ? theme.sidebarBg : theme.sidebarText, 0.56),
          name: 'filter-variant',
          size: 24,
        ),
      ),
    );
  }

  static getStyleSheet(Theme theme) {
    return {
      'container': BoxDecoration(
        color: changeOpacity(theme.sidebarText, 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      'filtered': BoxDecoration(
        color: theme.sidebarText,
      ),
    };
  }
}
