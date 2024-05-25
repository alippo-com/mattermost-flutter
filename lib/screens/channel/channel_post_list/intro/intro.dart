import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mattermost_flutter/constants/events.dart';
import 'package:mattermost_flutter/constants/general.dart';
import 'package:mattermost_flutter/context/server.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/store/ephemeral_store.dart';
import 'package:mattermost_flutter/hooks/use_did_update.dart';
import 'package:mattermost_flutter/screens/channel/channel_post_list/intro/direct_channel.dart';
import 'package:mattermost_flutter/screens/channel/channel_post_list/intro/public_or_private_channel.dart';
import 'package:mattermost_flutter/screens/channel/channel_post_list/intro/town_square.dart';
import 'package:mattermost_flutter/types/channel_model.dart';
import 'package:mattermost_flutter/types/role_model.dart';

const double PADDING_TOP = 100.0;

class Intro extends StatefulWidget {
  final ChannelModel? channel;
  final List<RoleModel> roles;

  Intro({this.channel, required this.roles});

  @override
  _IntroState createState() => _IntroState();
}

class _IntroState extends State<Intro> {
  bool fetching = false;

  @override
  void initState() {
    super.initState();
    final serverUrl = context.read<ServerUrl>().value;
    fetching = EphemeralStore.isLoadingMessagesForChannel(serverUrl, widget.channel?.id ?? '');
    DeviceEventEmitter.on(Events.LOADING_CHANNEL_POSTS, _onLoadingChannelPosts);
  }

  @override
  void didUpdateWidget(covariant Intro oldWidget) {
    super.didUpdateWidget(oldWidget);
    final serverUrl = context.read<ServerUrl>().value;
    fetching = EphemeralStore.isLoadingMessagesForChannel(serverUrl, widget.channel?.id ?? '');
  }

  @override
  void dispose() {
    DeviceEventEmitter.off(Events.LOADING_CHANNEL_POSTS, _onLoadingChannelPosts);
    super.dispose();
  }

  void _onLoadingChannelPosts(Map<String, dynamic> event) {
    final serverUrl = context.read<ServerUrl>().value;
    if (event['serverUrl'] == serverUrl && event['channelId'] == widget.channel?.id) {
      setState(() {
        fetching = event['value'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.read<Theme>();
    final roles = widget.roles;

    Widget? element;
    if (widget.channel != null) {
      if (widget.channel!.type == General.OPEN_CHANNEL && widget.channel!.name == General.DEFAULT_CHANNEL) {
        element = TownSquare(
          channelId: widget.channel!.id,
          displayName: widget.channel!.displayName,
          roles: roles,
          theme: theme,
        );
      } else {
        switch (widget.channel!.type) {
          case General.OPEN_CHANNEL:
          case General.PRIVATE_CHANNEL:
            element = PublicOrPrivateChannel(
              channel: widget.channel!,
              roles: roles,
              theme: theme,
            );
            break;
          default:
            element = DirectChannel(
              channel: widget.channel!,
              theme: theme,
            );
        }
      }
    }

    if (fetching) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(theme.centerChannelColor),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: PADDING_TOP),
      child: element,
    );
  }
}
