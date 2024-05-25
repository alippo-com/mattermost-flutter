import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mattermost_flutter/components/touchable_with_feedback.dart';
import 'package:mattermost_flutter/context/server.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/utils/server.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/typography.dart';
import 'package:mattermost_flutter/screens/home/channel_list/servers.dart';

const MARGIN_WITH_SERVER_ICON = 66;

class Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final intl = AppLocalizations.of(context);
    final theme = Provider.of<Theme>(context);
    final styles = getStyleSheet(theme);
    final serverDisplayName = Provider.of<ServerDisplayName>(context);
    final serverUrl = Provider.of<ServerUrl>(context);
    final managedConfig = Provider.of<ManagedConfig>(context);
    final canAddOtherServers = managedConfig?.allowOtherServers != 'false';
    final serverButtonRef = GlobalKey<ServersState>();

    final headerStyle = {
      ...styles.header,
      if (canAddOtherServers) 'marginLeft': MARGIN_WITH_SERVER_ICON,
    };

    void onLogoutPress() {
      alertServerLogout(serverDisplayName, () => logout(serverUrl), intl);
    }

    void onLabelPress() {
      serverButtonRef.current?.openServers();
    }

    Widget serverLabel = Text(
      serverDisplayName,
      style: styles.displayNameText,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );

    if (canAddOtherServers) {
      serverLabel = GestureDetector(
        onTap: onLabelPress,
        child: Container(
          child: serverLabel,
          style: styles.displayNameContainer,
        ),
      );
    }

    return Column(
      children: [
        if (canAddOtherServers) Servers(key: serverButtonRef),
        Container(
          margin: EdgeInsets.only(
            top: 20,
            left: 24,
            right: 24,
            ...headerStyle,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              serverLabel,
              GestureDetector(
                onTap: onLogoutPress,
                child: Container(
                  margin: EdgeInsets.only(left: 10),
                  child: Text(
                    intl.formatMessage('account.logout', defaultMessage: 'Log out'),
                    style: styles.logoutText,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Map<String, dynamic> getStyleSheet(Theme theme) {
    return {
      'header': {
        'flexDirection': 'row',
        'alignItems': 'center',
        'justifyContent': 'spaceBetween',
        'marginTop': 20,
        'marginHorizontal': 24,
      },
      'logoutText': {
        'color': changeOpacity(theme.sidebarText, 0.64),
        ...typography('Body', 100, 'SemiBold'),
      },
      'displayNameText': {
        'color': changeOpacity(theme.sidebarText, 0.64),
        ...typography('Body', 100, 'SemiBold'),
        'flex': 1,
      },
      'logoutContainer': {
        'marginLeft': 10,
      },
      'displayNameContainer': {
        'flex': 1,
      },
    };
  }
}
