// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:mattermost_flutter/components/option_item.dart';
import 'package:mattermost_flutter/context/server.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/utils/server.dart';
import 'package:mattermost_flutter/utils/tap.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/types/typography.dart';

class LogOut extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final theme = useTheme();
    final intl = useIntl();
    final serverUrl = useServerUrl();
    final serverDisplayName = useServerDisplayName();
    
    final styles = _getStyleSheet(theme);

    void onLogout() {
      preventDoubleTap(() {
        Navigator.of(context).pushReplacementNamed(Screens.HOME, arguments: {'extra': null});
        alertServerLogout(serverDisplayName, () => logout(serverUrl), intl);
      });
    }

    return OptionItem(
      action: onLogout,
      description: intl.formatMessage('account.logout_from', defaultMessage: 'Log out from', args: {'serverName': serverDisplayName}),
      destructive: true,
      icon: Icons.exit_to_app,
      label: intl.formatMessage('account.logout', defaultMessage: 'Log out'),
      optionDescriptionTextStyle: styles.desc,
      testID: 'account.logout.option',
      type: 'default',
    );
  }

  TextStyle _getStyleSheet(ThemeData theme) {
    return TextStyle(
      color: changeOpacity(theme.primaryColor, 0.64),
      fontSize: typography['Body'].size,
    );
  }
}
