
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mattermost_flutter/components/option.dart';
import 'package:mattermost_flutter/types/servers.dart';
import 'package:mattermost_flutter/utils/theme.dart';

class ServerOptions extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onLogin;
  final VoidCallback onLogout;
  final VoidCallback onRemove;
  final Animation<double> progress;
  final ServersModel server;

  ServerOptions({
    required this.onEdit,
    required this.onLogin,
    required this.onLogout,
    required this.onRemove,
    required this.progress,
    required this.server,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isLoggedIn = server.lastActiveAt > 0;
    final Color sessionColor = isLoggedIn ? const Color(0xFFF58B00) : theme.accentColor;
    final IconData sessionIcon = isLoggedIn ? Icons.logout : Icons.login;
    final String sessionText = isLoggedIn
        ? Intl.message('Log out', name: 'servers.logout', defaultMessage: 'Log out')
        : Intl.message('Log in', name: 'servers.login', defaultMessage: 'Log in');

    final String serverItem = 'server_list.server_item.${server.displayName.replaceAll(' ', '_').toLowerCase()}';
    final String loginOrLogoutOptionTestId = isLoggedIn ? '$serverItem.logout.option' : '$serverItem.login.option';

    return Row(
      children: [
        Option(
          color: changeOpacity(theme.primaryColor, 0.48),
          icon: Icons.edit,
          onPress: onEdit,
          progress: progress,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(8),
            bottomLeft: Radius.circular(8),
          ),
          testID: '$serverItem.edit.option',
          text: Intl.message('Edit', name: 'servers.edit', defaultMessage: 'Edit'),
        ),
        Option(
          color: theme.errorColor,
          icon: Icons.delete,
          onPress: onRemove,
          progress: progress,
          testID: '$serverItem.remove.option',
          text: Intl.message('Remove', name: 'servers.remove', defaultMessage: 'Remove'),
        ),
        Option(
          color: sessionColor,
          icon: sessionIcon,
          onPress: isLoggedIn ? onLogout : onLogin,
          progress: progress,
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(8),
            bottomRight: Radius.circular(8),
          ),
          testID: loginOrLogoutOptionTestId,
          text: sessionText,
        ),
      ],
    );
  }
}
