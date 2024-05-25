// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:mattermost_flutter/constants.dart';
import 'package:mattermost_flutter/i18n.dart';
import 'package:mattermost_flutter/components/compass_icon.dart';
import 'package:mattermost_flutter/screens/navigation.dart';
import 'package:mattermost_flutter/components/plus_menu_item.dart';
import 'package:mattermost_flutter/components/plus_menu_separator.dart';
import 'package:mattermost_flutter/context/theme.dart';

class PlusMenuList extends HookWidget {
  final bool canCreateChannels;
  final bool canJoinChannels;
  final bool canInvitePeople;

  PlusMenuList({
    required this.canCreateChannels,
    required this.canJoinChannels,
    required this.canInvitePeople,
  });

  @override
  Widget build(BuildContext context) {
    final intl = useIntl(context);
    final theme = useTheme(context);

    final browseChannels = useCallback(() async {
      await dismissBottomSheet(context);

      final title = intl.format('browse_channels.title', 'Browse channels');
      final closeButton = CompassIcon.getImageSourceSync('close', 24, theme.sidebarHeaderTextColor);

      showModal(context, Screens.BROWSE_CHANNELS, title, {
        'closeButton': closeButton,
      });
    }, [intl, theme]);

    final createNewChannel = useCallback(() async {
      await dismissBottomSheet(context);

      final title = intl.format('mobile.create_channel.title', 'New channel');
      showModal(context, Screens.CREATE_OR_EDIT_CHANNEL, title);
    }, [intl]);

    final openDirectMessage = useCallback(() async {
      await dismissBottomSheet(context);

      final title = intl.format('create_direct_message.title', 'Create Direct Message');
      final closeButton = CompassIcon.getImageSourceSync('close', 24, theme.sidebarHeaderTextColor);
      showModal(context, Screens.CREATE_DIRECT_MESSAGE, title, {
        'closeButton': closeButton,
      });
    }, [intl, theme]);

    final invitePeopleToTeam = useCallback(() async {
      await dismissBottomSheet(context);

      showModal(
        context,
        Screens.INVITE,
        intl.format('invite.title', 'Invite'),
      );
    }, [intl, theme]);

    return Column(
      children: [
        if (canJoinChannels)
          PlusMenuItem(
            pickerAction: 'browseChannels',
            onPress: browseChannels,
          ),
        if (canCreateChannels)
          PlusMenuItem(
            pickerAction: 'createNewChannel',
            onPress: createNewChannel,
          ),
        PlusMenuItem(
          pickerAction: 'openDirectMessage',
          onPress: openDirectMessage,
        ),
        if (canInvitePeople) ...[
          PlusMenuSeparator(),
          PlusMenuItem(
            pickerAction: 'invitePeopleToTeam',
            onPress: invitePeopleToTeam,
          ),
        ],
      ],
    );
  }
}
