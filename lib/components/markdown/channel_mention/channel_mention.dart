import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mattermost_flutter/queries/servers/channel.dart';
import 'package:mattermost_flutter/utils/tap.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/i18n.dart';
import 'package:mattermost_flutter/components/alert.dart';

class ChannelMentions {
  final String? id;
  final String displayName;
  final String? name;
  final String teamName;

  ChannelMentions({this.id, required this.displayName, this.name, required this.teamName});
}

class ChannelMentionProps {
  final Map<String, ChannelMentions>? channelMentions;
  final String channelName;
  final List<ChannelModel> channels;
  final String currentTeamId;
  final TextStyle linkStyle;
  final TeamModel team;
  final TextStyle textStyle;

  ChannelMentionProps({
    this.channelMentions,
    required this.channelName,
    required this.channels,
    required this.currentTeamId,
    required this.linkStyle,
    required this.team,
    required this.textStyle,
  });
}

ChannelMentions? getChannelFromChannelName(
    String name, List<ChannelModel> channels, Map<String, ChannelMentions>? channelMentions, String teamName) {
  final channelsByName = channelMentions ?? {};
  var channelName = name;

  for (final c in channels) {
    channelsByName[c.name] = ChannelMentions(
      id: c.id,
      displayName: c.displayName,
      name: c.name,
      teamName: teamName,
    );
  }

  while (channelName.isNotEmpty) {
    if (channelsByName.containsKey(channelName)) {
      return channelsByName[channelName];
    }

    if (RegExp(r'[_-]$').hasMatch(channelName)) {
      channelName = channelName.substring(0, channelName.length - 1);
    } else {
      break;
    }
  }

  return null;
}

class ChannelMention extends StatelessWidget {
  final ChannelMentionProps props;

  ChannelMention({required this.props});

  @override
  Widget build(BuildContext context) {
    final intl = useIntl(context);
    final serverUrl = useServerUrl(context);
    final channel = getChannelFromChannelName(props.channelName, props.channels, props.channelMentions, props.team.name);

    void handlePress() async {
      var c = channel;

      if (c?.id == null && c?.displayName != null) {
        final result = await joinChannel(serverUrl, props.currentTeamId, null, props.channelName);
        if (result.error != null || result.channel == null) {
          final joinFailedMessage = intl.formatMessage(
            id: 'mobile.join_channel.error',
            defaultMessage: "We couldn't join the channel {displayName}.",
            values: {'displayName': c!.displayName},
          );
          alertErrorWithFallback(context, result.error, joinFailedMessage);
        } else if (result.channel != null) {
          c = ChannelMentions(
            id: result.channel.id,
            name: result.channel.name,
            displayName: c!.displayName,
            teamName: c.teamName,
          );
        }
      }

      if (c?.id != null) {
        switchToChannelById(serverUrl, c!.id!);
      }
    }

    if (channel == null) {
      return Text('~${props.channelName}', style: props.textStyle);
    }

    String? suffix;
    if (channel.name != null) {
      suffix = props.channelName.substring(channel.name!.length);
    }

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '~${channel.displayName}',
            style: props.linkStyle,
            recognizer: TapGestureRecognizer()..onTap = handlePress,
          ),
          if (suffix != null) TextSpan(text: suffix),
        ],
      ),
      style: props.textStyle,
    );
  }
}
