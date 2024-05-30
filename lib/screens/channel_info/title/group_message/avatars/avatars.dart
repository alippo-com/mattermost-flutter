// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:mattermost_flutter/context/server.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:mattermost_flutter/types/user.dart';

class GroupAvatars extends StatelessWidget {
  final List<UserModel> users;

  GroupAvatars({required this.users});

  @override
  Widget build(BuildContext context) {
    final serverUrl = useServerUrl(context);
    final theme = useTheme(context);
    final styles = getStyleSheet(theme);

    Client? client;

    try {
      client = NetworkManager.getClient(serverUrl);
    } catch {
      return Container();
    }

    List<Widget> group = users.asMap().entries.map((entry) {
      int i = entry.key;
      UserModel u = entry.value;
      final pictureUrl = client!.getProfilePictureUrl(u.id, u.lastPictureUpdate);
      return CachedNetworkImage(
        key: ValueKey(pictureUrl + i.toString()),
        imageUrl: '$serverUrl$pictureUrl',
        imageBuilder: (context, imageProvider) => Container(
          decoration: BoxDecoration(
            image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: theme.centerChannelBg,
              width: 2,
            ),
          ),
          width: 48,
          height: 48,
          margin: EdgeInsets.only(left: -(i * 12).toDouble()),
        ),
      );
    }).toList();

    return Container(
      alignment: Alignment.center,
      margin: EdgeInsets.only(bottom: 8),
      child: Row(
        children: group,
      ),
    );
  }

  getStyleSheet(Theme theme) {
    return {
      'container': BoxDecoration(
        alignItems: 'center',
        flexDirection: 'row',
        marginBottom: 8,
      ),
      'profile': BoxDecoration(
        borderColor: theme.centerChannelBg,
        borderRadius: BorderRadius.circular(24),
        borderWidth: 2,
        height: 48,
        width: 48,
      ),
    };
  }
}
