import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:intl/intl.dart';

import 'package:mattermost_flutter/actions/remote/channel.dart';
import 'package:mattermost_flutter/components/compass_icon.dart';
import 'package:mattermost_flutter/constants.dart';
import 'package:mattermost_flutter/context/server.dart';
import 'package:mattermost_flutter/i18n.dart';
import 'package:mattermost_flutter/utils/role.dart';
import 'package:mattermost_flutter/utils/theme.dart';

import 'private_channel.dart';
import 'public_channel.dart';
import 'intro_options.dart';

class PublicOrPrivateChannel extends HookWidget {
  final ChannelModel channel;
  final String? creator;
  final List<RoleModel> roles;
  final Theme theme;

  PublicOrPrivateChannel({
    required this.channel,
    this.creator,
    required this.roles,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final intl = useIntl();
    final serverUrl = useServerUrl();
    final styles = _getStyleSheet(theme);
    final illustration = useMemo(() {
      if (channel.type == General.OPEN_CHANNEL) {
        return PublicChannel(theme: theme);
      }
      return PrivateChannel(theme: theme);
    }, [channel.type, theme]);

    useEffect(() {
      if (creator == null && channel.creatorId != null) {
        fetchChannelCreator(serverUrl, channel.id);
      }
    }, []);

    final canManagePeople = useMemo(() {
      if (channel.deleteAt != 0) {
        return false;
      }
      final permission = channel.type == General.OPEN_CHANNEL 
          ? Permissions.MANAGE_PUBLIC_CHANNEL_MEMBERS 
          : Permissions.MANAGE_PRIVATE_CHANNEL_MEMBERS;
      return hasPermission(roles, permission);
    }, [channel.type, roles, channel.deleteAt]);

    final canSetHeader = useMemo(() {
      if (channel.deleteAt != 0) {
        return false;
      }
      final permission = channel.type == General.OPEN_CHANNEL 
          ? Permissions.MANAGE_PUBLIC_CHANNEL_PROPERTIES 
          : Permissions.MANAGE_PRIVATE_CHANNEL_PROPERTIES;
      return hasPermission(roles, permission);
    }, [channel.type, roles, channel.deleteAt]);

    final createdBy = useMemo(() {
      final id = channel.type == General.OPEN_CHANNEL 
          ? t('intro.public_channel') 
          : t('intro.private_channel');
      final defaultMessage = channel.type == General.OPEN_CHANNEL 
          ? 'Public Channel' 
          : 'Private Channel';
      final channelType = '${intl.formatMessage(id: id, defaultMessage: defaultMessage)} ';

      final date = DateFormat.yMMMMd().format(DateTime.fromMillisecondsSinceEpoch(channel.createAt));
      final by = intl.formatMessage(id: 'intro.created_by', defaultMessage: 'created by {creator} on {date}.', args: {
        'creator': creator,
        'date': date,
      });

      return '$channelType $by';
    }, [channel.type, creator, theme]);

    final message = useMemo(() {
      final id = channel.type == General.OPEN_CHANNEL 
          ? t('intro.welcome.public') 
          : t('intro.welcome.private');
      final msg = channel.type == General.OPEN_CHANNEL 
          ? 'Add some more team members to the channel or start a conversation below.' 
          : 'Only invited members can see messages posted in this private channel.';
      final mainMessage = intl.formatMessage(id: 'intro.welcome', defaultMessage: 'Welcome to {displayName} channel.', args: {
        'displayName': channel.displayName,
      });

      final suffix = intl.formatMessage(id: id, defaultMessage: msg);

      return '$mainMessage $suffix';
    }, [channel.displayName, channel.type, theme]);

    return Column(
      children: [
        illustration,
        Text(
          channel.displayName,
          style: styles.title,
          key: Key('channel_post_list.intro.display_name'),
        ),
        Row(
          children: [
            CompassIcon(
              name: channel.type == General.OPEN_CHANNEL ? 'globe' : 'lock',
              size: 14.4,
              color: changeOpacity(theme.centerChannelColor, 0.64),
              style: styles.icon,
            ),
            Text(
              createdBy,
              style: styles.created,
            ),
          ],
        ),
        Text(
          message,
          style: styles.message,
        ),
        IntroOptions(
          channelId: channel.id,
          header: canSetHeader,
          canAddMembers: canManagePeople,
        ),
      ],
    );
  }

  _getStyleSheet(Theme theme) {
    return {
      'container': BoxDecoration(
        alignItems: Alignment.center,
        marginHorizontal: 20.0,
      ),
      'created': TextStyle(
        color: changeOpacity(theme.centerChannelColor, 0.64),
        // typography equivalent in Flutter
      ),
      'icon': BoxDecoration(
        marginRight: 5.0,
      ),
      'message': TextStyle(
        color: theme.centerChannelColor,
        marginTop: 16.0,
        textAlign: TextAlign.center,
        // typography equivalent in Flutter
      ),
      'title': TextStyle(
        color: theme.centerChannelColor,
        marginTop: 8.0,
        marginBottom: 8.0,
        textAlign: TextAlign.center,
        // typography equivalent in Flutter
      ),
    };
  }
}
