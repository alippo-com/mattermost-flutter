import 'package:flutter/material.dart';
import 'package:mattermost_flutter/components/profile_picture.dart';
import 'package:mattermost_flutter/types/user.dart';

class AccountUserInfo extends StatelessWidget {
  final UserModel user;
  final bool showFullName;
  final ThemeData theme;

  AccountUserInfo({required this.user, required this.showFullName, required this.theme});

  @override
  Widget build(BuildContext context) {
    final styles = getStyleSheet(theme);
    final nickName = user.nickname != null ? ' (${user.nickname})' : '';
    final title = '${user.firstName} ${user.lastName}${nickName}';
    final userName = '@${user.username}';
    final accountUserInfoTestId = 'account.user_info.${user.id}';

    return Container(
      color: theme.sidebarBg,
      padding: const EdgeInsets.only(bottom: 20, top: 22, left: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ProfilePicture(
            size: 120,
            iconSize: 28,
            showStatus: true,
            author: user,
            statusStyle: styles['statusStyle'],
            statusSize: 24,
            testID: '${accountUserInfoTestId}.profile_picture',
          ),
          if (showFullName)
            Text(
              title,
              style: styles['textFullName'],
              key: Key('${accountUserInfoTestId}.display_name'),
            ),
          Text(
            userName,
            style: showFullName ? styles['textUserName'] : styles['textFullName'],
            key: Key('${accountUserInfoTestId}.username'),
          ),
        ],
      ),
    );
  }

  Map<String, TextStyle> getStyleSheet(ThemeData theme) {
    return {
      'container': TextStyle(
        backgroundColor: theme.sidebarBg,
        fontSize: 16,
      ),
      'statusStyle': TextStyle(
        color: theme.sidebarBg,
      ),
      'textFullName': TextStyle(
        fontSize: 28,
        height: 36 / 28,
        color: theme.sidebarText,
        fontFamily: 'Metropolis-SemiBold',
        marginTop: 16,
      ),
      'textUserName': TextStyle(
        fontSize: 16,
        height: 24 / 16,
        color: theme.sidebarText,
        fontFamily: 'OpenSans',
        marginTop: 4,
      ),
    };
  }
}
