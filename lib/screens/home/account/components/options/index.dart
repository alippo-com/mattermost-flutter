
// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/widgets/custom_status.dart';
import 'package:mattermost_flutter/widgets/logout.dart';
import 'package:mattermost_flutter/widgets/settings.dart';
import 'package:mattermost_flutter/widgets/user_presence.dart';
import 'package:mattermost_flutter/widgets/your_profile.dart';


class AccountOptions extends StatelessWidget {
  final UserModel user;
  final bool enableCustomUserStatuses;
  final bool isTablet;
  final ThemeData theme;

  AccountOptions({
    required this.user,
    required this.enableCustomUserStatuses,
    required this.isTablet,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final styles = getStyleSheet(theme);

    return Container(
      decoration: BoxDecoration(
        color: theme.centerChannelBg,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            offset: Offset(0, -2),
            blurRadius: 6,
          ),
        ],
      ),
      padding: EdgeInsets.only(top: 12),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.only(left: 16),
            child: Column(
              children: [
                UserPresence(currentUser: user),
                if (enableCustomUserStatuses)
                  CustomStatus(isTablet: isTablet, currentUser: user),
              ],
            ),
          ),
          Divider(
            color: changeOpacity(theme.centerChannelColor, 0.2),
            thickness: 1,
            indent: 20,
            endIndent: 20,
          ),
          Container(
            padding: EdgeInsets.only(left: 16),
            child: Column(
              children: [
                YourProfile(isTablet: isTablet, theme: theme),
                Settings(),
              ],
            ),
          ),
          Divider(
            color: changeOpacity(theme.centerChannelColor, 0.2),
            thickness: 1,
            indent: 20,
            endIndent: 20,
          ),
          Container(
            padding: EdgeInsets.only(left: 16),
            child: Column(
              children: [
                Logout(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Map<String, TextStyle> getStyleSheet(ThemeData theme) {
    return {
      'container': TextStyle(
        color: theme.centerChannelBg,
      ),
      'divider': TextStyle(
        color: changeOpacity(theme.centerChannelColor, 0.2),
      ),
      'group': TextStyle(
        paddingLeft: 16,
      ),
    };
  }
}
