import 'package:flutter/material.dart';
import 'package:mattermost_flutter/components/loading.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/typography.dart';
import 'package:mattermost_flutter/network/channel.dart';
import 'package:mattermost_flutter/constants/constants.dart';
import 'convert_gm_to_channel_form.dart';

class ConvertGMToChannel extends StatefulWidget {
  final String channelId;
  final String? currentUserId;

  const ConvertGMToChannel({
    required this.channelId,
    this.currentUserId,
  });

  @override
  _ConvertGMToChannelState createState() => _ConvertGMToChannelState();
}

class _ConvertGMToChannelState extends State<ConvertGMToChannel> {
  bool loadingAnimationTimeout = false;
  bool commonTeamsFetched = false;
  bool channelMembersFetched = false;
  List<Team> commonTeams = [];
  List<UserProfile> profiles = [];
  late String serverUrl;
  late Timer loadingAnimationTimeoutTimer;

  @override
  void initState() {
    super.initState();
    serverUrl = ''; // Fetch server URL from context or other means

    loadingAnimationTimeoutTimer = Timer(Duration(milliseconds: 1200), () {
      setState(() {
        loadingAnimationTimeout = true;
      });
    });

    fetchGroupMessageMembersCommonTeams(serverUrl, widget.channelId).then((teams) {
      if (teams != null) {
        setState(() {
          commonTeams = teams;
          commonTeamsFetched = true;
        });
      }
    });

    if (widget.currentUserId != null) {
      fetchChannelMemberships(serverUrl, widget.channelId, {'sort': 'admin', 'active': true, 'per_page': PER_PAGE_DEFAULT}).then((result) {
        if (result != null) {
          setState(() {
            profiles = matchUserProfiles(result.users, result.members, widget.currentUserId!);
            channelMembersFetched = true;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    loadingAnimationTimeoutTimer.cancel();
    super.dispose();
  }

  List<UserProfile> matchUserProfiles(List<UserProfile> users, List<ChannelMembership> members, String currentUserId) {
    final usersById = {for (var profile in users) if (profile.id != currentUserId) profile.id: profile};
    return members.where((member) => usersById.containsKey(member.userId)).map((member) => usersById[member.userId]!).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final styles = _getStyleFromTheme(theme);

    final showLoader = !loadingAnimationTimeout || !commonTeamsFetched || !channelMembersFetched;

    if (showLoader) {
      return Loading(
        containerStyle: styles['loadingContainer'],
        size: 'large',
        color: theme.buttonColor,
        footerText: 'Fetching details...',
        footerTextStyles: styles['text'],
      );
    }

    return ConvertGMToChannelForm(
      commonTeams: commonTeams,
      profiles: profiles,
      channelId: widget.channelId,
    );
  }

  Map<String, dynamic> _getStyleFromTheme(ThemeData theme) {
    return {
      'loadingContainer': {
        'justifyContent': MainAxisAlignment.center,
        'alignItems': Alignment.center,
        'flex': 1,
        'gap': 24.0,
      },
      'text': {
        'color': changeOpacity(theme.primaryColor, 0.56),
        'fontSize': typography('Body', 300, 'SemiBold').fontSize,
      },
      'container': {
        'paddingVertical': 24.0,
        'paddingHorizontal': 20.0,
        'display': 'flex',
        'flexDirection': Axis.vertical,
        'gap': 24.0,
      },
    };
  }
}
