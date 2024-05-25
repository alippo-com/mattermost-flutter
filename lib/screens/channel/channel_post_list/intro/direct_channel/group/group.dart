import 'package:flutter/material.dart';
import 'package:fast_image/fast_image.dart';
import 'package:collection/collection.dart';

import 'package:mattermost_flutter/context/server.dart';
import 'package:mattermost_flutter/managers/network_manager.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/types/database/models/servers/user.dart';

class Group extends StatelessWidget {
  final ThemeData theme;
  final List<UserModel> users;

  Group({required this.theme, required this.users});

  @override
  Widget build(BuildContext context) {
    final serverUrl = useServerUrl(context);
    final styles = _getStyleSheet(theme);

    Client? client;
    try {
      client = NetworkManager.getClient(serverUrl);
    } catch (e) {
      return SizedBox.shrink();
    }

    final rows = partition(users, 5);
    final groups = rows.mapIndexed((k, c) {
      final group = c.mapIndexed((i, u) {
        final pictureUrl = client!.getProfilePictureUrl(u.id, u.lastPictureUpdate);
        return FastImage(
          key: Key(pictureUrl + i.toString()),
          style: styles.profile.copyWith(transform: [Matrix4.translationValues(-(i * 24.0), 0, 0)]),
          source: FastImageSource.network('${serverUrl}${pictureUrl}'),
        );
      }).toList();

      return Positioned(
        key: Key('group_avatar' + k.toString()),
        left: (c.length - 1) * 12.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: group,
        ),
      );
    }).toList();

    return Column(
      children: groups,
    );
  }

  _getStyleSheet(ThemeData theme) {
    return _GroupStyles(
      container: BoxDecoration(
        alignItems: Alignment.center,
        flexDirection: Axis.horizontal,
        margin: EdgeInsets.only(bottom: 12),
      ),
      profile: BoxDecoration(
        border: Border.all(color: theme.centerChannelBg),
        borderRadius: BorderRadius.circular(36),
        borderWidth: 2,
        height: 72,
        width: 72,
      ),
    );
  }
}

class _GroupStyles {
  final BoxDecoration container;
  final BoxDecoration profile;

  _GroupStyles({
    required this.container,
    required this.profile,
  });
}
``