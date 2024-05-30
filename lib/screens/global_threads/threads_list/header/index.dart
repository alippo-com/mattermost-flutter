import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:mattermost_flutter/utils/tap.dart'; // Custom utility to prevent double tap
import 'package:mattermost_flutter/utils/theme.dart'; // Custom theming utilities
import 'package:mattermost_flutter/components/compass_icon.dart'; // Custom icon component
import 'package:mattermost_flutter/components/formatted_text.dart'; // Custom formatted text component
import 'package:mattermost_flutter/context/server.dart'; // Custom server context
import 'package:mattermost_flutter/context/theme.dart'; // Custom theme context
// Custom action to update threads

class Header extends HookWidget {
  final Function(String) setTab;
  final String tab;
  final String teamId;
  final String testID;
  final int unreadsCount;

  Header({required this.setTab, required this.tab, required this.teamId, required this.testID, required this.unreadsCount});

  @override
  Widget build(BuildContext context) {
    final theme = useTheme();
    final intl = useIntl();
    final serverUrl = useServerUrl();
    final hasUnreads = unreadsCount > 0;
    final viewingUnreads = tab == 'unreads';

    final styles = _getStyleSheet(theme);

    final handleMarkAllAsRead = useCallback(() {
      preventDoubleTap(() {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(intl.formatMessage(id: 'global_threads.markAllRead.title', defaultMessage: 'Are you sure you want to mark all threads as read?')),
              content: Text(intl.formatMessage(id: 'global_threads.markAllRead.message', defaultMessage: 'This will clear any unread status for all of your threads shown here')),
              actions: <Widget>[
                TextButton(
                  child: Text(intl.formatMessage(id: 'global_threads.markAllRead.cancel', defaultMessage: 'Cancel')),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text(intl.formatMessage(id: 'global_threads.markAllRead.markRead', defaultMessage: 'Mark read')),
                  onPressed: () {
                    updateTeamThreadsAsRead(serverUrl, teamId);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      });
    }, [intl, serverUrl, teamId]);

    final handleViewAllThreads = useCallback(() => setTab('all'), [setTab]);
    final handleViewUnreadThreads = useCallback(() => setTab('unreads'), [setTab]);

    final allThreadsContainerStyle = useMemo(() {
      return [
        styles['menuItemContainer']!,
        !viewingUnreads ? styles['menuItemContainerSelected'] : null,
      ];
    }, [styles, viewingUnreads]);

    final allThreadsStyle = useMemo(() {
      return [
        styles['menuItem']!,
        !viewingUnreads ? styles['menuItemSelected'] : null,
      ];
    }, [styles, viewingUnreads]);

    final unreadsContainerStyle = useMemo(() {
      return [
        styles['menuItemContainer']!,
        viewingUnreads ? styles['menuItemContainerSelected'] : null,
      ];
    }, [styles, viewingUnreads]);

    final unreadsStyle = useMemo(() {
      return [
        styles['menuItem']!,
        viewingUnreads ? styles['menuItemSelected'] : null,
      ];
    }, [styles, viewingUnreads]);

    final markAllStyle = useMemo(() {
      return [
        styles['markAllReadIcon']!,
        hasUnreads ? null : styles['markAllReadIconDisabled'],
      ];
    }, [styles, hasUnreads]);

    return Container(
      decoration: styles['container']!,
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: styles['menuContainer']!,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: handleViewAllThreads,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Column(
                        children: [
                          FormattedText(
                            id: 'global_threads.allThreads',
                            defaultMessage: 'All your threads',
                            style: allThreadsStyle,
                          ),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: handleViewUnreadThreads,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Column(
                        children: [
                          FormattedText(
                            id: 'global_threads.unreads',
                            defaultMessage: 'Unreads',
                            style: unreadsStyle,
                          ),
                          hasUnreads
                              ? Container(
                                  decoration: styles['unreadsDot']!,
                                )
                              : Container(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            decoration: styles['markAllReadIconContainer']!,
            child: GestureDetector(
              onTap: hasUnreads ? handleMarkAllAsRead : null,
              child: CompassIcon(
                name: 'playlist-check',
                style: markAllStyle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, BoxDecoration?> _getStyleSheet(ThemeData theme) {
    return {
      'container': BoxDecoration(
        border: Border(bottom: BorderSide(color: theme.centerChannelColor.withOpacity(0.08), width: 1)),
      ),
      'menuContainer': BoxDecoration(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      ),
      'menuItemContainer': BoxDecoration(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      ),
      'menuItemContainerSelected': BoxDecoration(
        color: theme.buttonBg.withOpacity(0.08),
        borderRadius: BorderRadius.circular(4),
      ),
      'menuItem': TextStyle(
        color: theme.centerChannelColor.withOpacity(0.56),
        fontWeight: FontWeight.w600,
        fontSize: 16,
      ),
      'menuItemSelected': TextStyle(
        color: theme.buttonBg,
      ),
      'unreadsDot': BoxDecoration(
        color: theme.sidebarTextActiveBorder,
        shape: BoxShape.circle,
        width: 6,
        height: 6,
      ),
      'markAllReadIconContainer': BoxDecoration(
        padding: EdgeInsets.symmetric(horizontal: 20),
      ),
      'markAllReadIcon': TextStyle(
        fontSize: 28,
        color: theme.centerChannelColor.withOpacity(0.56),
      ),
      'markAllReadIconDisabled': TextStyle(
        fontSize: 28,
        color: theme.centerChannelColor.withOpacity(0.56),
        opacity: 0.5,
      ),
    };
  }
}
