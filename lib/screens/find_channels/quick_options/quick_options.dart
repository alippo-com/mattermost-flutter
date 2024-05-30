
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mattermost_flutter/constants.dart';
import 'package:mattermost_flutter/components/option_box.dart';
import 'package:mattermost_flutter/utils/compass_icon.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/models/permission_model.dart';
import 'package:mattermost_flutter/services/permissions_service.dart';
import 'package:mattermost_flutter/services/team_service.dart';
import 'package:mattermost_flutter/services/user_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:rxdart/rxdart.dart';

class QuickOptionsContainer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final database = Provider.of<Database>(context);

    return StreamBuilder<Team>(
      stream: observeCurrentTeam(database),
      builder: (context, teamSnapshot) {
        if (!teamSnapshot.hasData) {
          return CircularProgressIndicator();
        }
        final team = teamSnapshot.data!;

        return StreamBuilder<User>(
          stream: observeCurrentUser(database),
          builder: (context, userSnapshot) {
            if (!userSnapshot.hasData) {
              return CircularProgressIndicator();
            }
            final user = userSnapshot.data!;

            final canJoinChannels = observePermissionForTeam(database, team, user, Permissions.JOIN_PUBLIC_CHANNELS, true);
            final canCreatePublicChannels = observePermissionForTeam(database, team, user, Permissions.CREATE_PUBLIC_CHANNEL, true);
            final canCreatePrivateChannels = observePermissionForTeam(database, team, user, Permissions.CREATE_PRIVATE_CHANNEL, false);
            final canCreateChannels = Rx.combineLatest2(
              canCreatePublicChannels,
              canCreatePrivateChannels,
              (bool open, bool priv) => open or priv,
            );

            return StreamBuilder<bool>(
              stream: canJoinChannels,
              builder: (context, canJoinChannelsSnapshot) {
                if (!canJoinChannelsSnapshot.hasData) {
                  return CircularProgressIndicator();
                }

                return StreamBuilder<bool>(
                  stream: canCreateChannels,
                  builder: (context, canCreateChannelsSnapshot) {
                    if (!canCreateChannelsSnapshot.hasData) {
                      return CircularProgressIndicator();
                    }

                    return QuickOptions(
                      canCreateChannels: canCreateChannelsSnapshot.data!,
                      canJoinChannels: canJoinChannelsSnapshot.data!,
                      close: () async {},
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}

class QuickOptions extends StatelessWidget {
  final bool canCreateChannels;
  final bool canJoinChannels;
  final Future<void> Function() close;

  QuickOptions({
    required this.canCreateChannels,
    required this.canJoinChannels,
    required this.close,
  });

  @override
  Widget build(BuildContext context) {
    final theme = useTheme(context);
    final intl = AppLocalizations.of(context)!;

    Future<void> browseChannels() async {
      final title = intl.browse_channels_title;
      final closeButton = await CompassIcon.getImageSource('close', 24, theme.sidebarHeaderTextColor);

      await close();
      showModal(context, Screens.BROWSE_CHANNELS, title, {
        'closeButton': closeButton,
      });
    }

    Future<void> createNewChannel() async {
      final title = intl.mobile_create_channel_title;

      await close();
      showModal(context, Screens.CREATE_OR_EDIT_CHANNEL, title);
    }

    Future<void> openDirectMessage() async {
      final title = intl.create_direct_message_title;
      final closeButton = await CompassIcon.getImageSource('close', 24, theme.sidebarHeaderTextColor);

      await close();
      showModal(context, Screens.CREATE_DIRECT_MESSAGE, title, {
        'closeButton': closeButton,
      });
    }

    return Container(
      margin: const EdgeInsets.only(top: 20),
      alignment: Alignment.center,
      child: Column(
        children: [
          if (canJoinChannels) ...[
            OptionBox(
              iconName: 'globe',
              onPress: browseChannels,
              text: intl.find_channels_directory,
              testID: 'find_channels.quick_options.directory.option',
            ),
            SizedBox(width: 8),
          ],
          OptionBox(
            iconName: 'account-outline',
            onPress: openDirectMessage,
            text: intl.find_channels_open_dm,
            testID: 'find_channels.quick_options.open_dm.option',
          ),
          if (canCreateChannels) ...[
            SizedBox(width: 8),
            OptionBox(
              iconName: 'plus',
              onPress: createNewChannel,
              text: intl.find_channels_new_channel,
              testID: 'find_channels.quick_options.new_channel.option',
            ),
          ],
        ],
      ),
    );
  }
}
