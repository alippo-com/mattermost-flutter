// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fast_image/fast_image.dart';
import 'package:mattermost_flutter/constants/general.dart';
import 'package:mattermost_flutter/queries/system.dart';
import 'package:mattermost_flutter/queries/user.dart';
import 'package:mattermost_flutter/types/database/models/user.dart';

class NotificationIcon extends StatelessWidget {
  final UserModel? author;
  final bool enablePostIconOverride;
  final bool fromWebhook;
  final String? overrideIconUrl;
  final String serverUrl;
  final bool useUserIcon;

  NotificationIcon({
    this.author,
    required this.enablePostIconOverride,
    required this.fromWebhook,
    this.overrideIconUrl,
    required this.serverUrl,
    required this.useUserIcon,
  });

  @override
  Widget build(BuildContext context) {
    final client = NetworkManager.getClient(serverUrl);

    Widget icon;
    if (client != null && fromWebhook && !useUserIcon && enablePostIconOverride) {
      if (overrideIconUrl != null) {
        final source = FastImageProvider.uri(client.getAbsoluteUrl(overrideIconUrl!));
        icon = FastImage(
          source: source,
          style: iconStyle,
        );
      } else {
        icon = Icon(
          Icons.webhook,
          size: IMAGE_SIZE,
        );
      }
    } else if (author != null && client != null) {
      final pictureUrl = client.getProfilePictureUrl(author!.id, author!.lastPictureUpdate);
      icon = FastImage(
        key: ValueKey(pictureUrl),
        style: iconStyle,
        source: FastImageProvider.uri('$serverUrl$pictureUrl'),
      );
    } else {
      icon = Image.asset(
        'assets/images/icon.png',
        style: iconStyle,
      );
    }

    return Container(
      child: icon,
    );
  }

  static const double IMAGE_SIZE = 36.0;
  static const iconStyle = BoxDecoration(
    borderRadius: BorderRadius.all(Radius.circular(IMAGE_SIZE / 2)),
    height: IMAGE_SIZE,
    width: IMAGE_SIZE,
  );
}

class EnhancedNotificationIcon extends StatelessWidget {
  final String senderId;

  EnhancedNotificationIcon({required this.senderId});

  @override
  Widget build(BuildContext context) {
    final database = Provider.of<Database>(context);
    final author = observeUser(database, senderId);
    final enablePostIconOverride = observeConfigBooleanValue(database, 'EnablePostIconOverride');

    return StreamBuilder(
      stream: CombineLatestStream.list([author, enablePostIconOverride]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }

        final data = snapshot.data as List<dynamic>;
        final author = data[0];
        final enablePostIconOverride = data[1];

        return NotificationIcon(
          author: author,
          enablePostIconOverride: enablePostIconOverride,
          fromWebhook: false,
          overrideIconUrl: null,
          serverUrl: '', // Provide the server URL
          useUserIcon: false,
        );
      },
    );
  }
}
