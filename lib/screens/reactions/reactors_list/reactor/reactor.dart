// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:mattermost_flutter/constants/screens.dart';
import 'package:mattermost_flutter/contexts/server.dart';
import 'package:mattermost_flutter/contexts/theme.dart';
import 'package:mattermost_flutter/components/user_item.dart';
import 'package:mattermost_flutter/actions/navigation.dart';
import 'package:mattermost_flutter/actions/remote/user.dart';
import 'package:mattermost_flutter/types/database/models/servers/reaction.dart';
import 'package:mattermost_flutter/types/database/models/servers/user.dart';

class Reactor extends HookWidget {
  final String channelId;
  final String location;
  final ReactionModel reaction;
  final UserModel? user;

  const Reactor({
    Key? key,
    required this.channelId,
    required this.location,
    required this.reaction,
    this.user,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final intl = useIntl();
    final theme = useTheme();
    final serverUrl = useServerUrl();

    useEffect(() {
      if (user == null) {
        fetchUsersByIds(serverUrl, [reaction.userId]);
      }
    }, []);

    void openUserProfile() async {
      if (user != null) {
        await dismissBottomSheet(Screens.reactions);
        const screen = Screens.userProfile;
        final title = intl.formatMessage(id: 'mobile.routes.user_profile', defaultMessage: 'Profile');
        const closeButtonId = 'close-user-profile';
        final props = {
          'closeButtonId': closeButtonId,
          'location': location,
          'userId': user!.id,
          'channelId': channelId,
        };

        FocusScope.of(context).unfocus();
        openAsBottomSheet(screen: screen, title: title, theme: theme, closeButtonId: closeButtonId, props: props);
      }
    }

    return UserItem(
      user: user,
      testID: 'reactions.reactor_item',
      onUserPress: openUserProfile,
    );
  }
}
