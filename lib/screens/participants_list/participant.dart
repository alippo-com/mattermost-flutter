
import 'package:flutter/material.dart';
import 'package:mattermost_flutter/types/calls.dart';
import 'package:mattermost_flutter/state/calls.dart';
import 'package:mattermost_flutter/components/call_avatar.dart';
import 'package:mattermost_flutter/components/calls_badge.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/typography.dart';
import 'package:mattermost_flutter/utils/user.dart';

const AVATAR_SIZE_LARGE = 40.0;
const AVATAR_SIZE_MEDIUM = 32.0;

class ParticipantCard extends StatelessWidget {
  final CallSession session;
  final bool smallerAvatar;
  final String teammateNameDisplay;
  final VoidCallback onPress;
  final VoidCallback onLongPress;

  ParticipantCard({
    required this.session,
    required this.smallerAvatar,
    required this.teammateNameDisplay,
    required this.onPress,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = useTheme(context);
    final currentCall = useCurrentCall(context);
    final callsTheme = makeCallsTheme(theme);
    final style = getStyleSheet(callsTheme);

    if (currentCall == null || currentCall.sessions[currentCall.mySessionId] == null) {
      return SizedBox.shrink();
    }

    final mySession = currentCall.sessions[currentCall.mySessionId]!;
    final screenShareOn = currentCall.screenOn.isNotEmpty;
    final avatarSize = smallerAvatar ? AVATAR_SIZE_MEDIUM : AVATAR_SIZE_LARGE;

    return GestureDetector(
      onTap: onPress,
      onLongPress: onLongPress,
      child: Builder(
        builder: (context) {
          final pressed = context.findAncestorStateOfType<State<GestureDetector>>()?.mounted ?? false;
          return Container(
            key: Key(session.sessionId),
            margin: EdgeInsets.only(top: 5.0, bottom: screenShareOn ? 0.0 : 5.0),
            padding: EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: pressed ? changeOpacity(theme.sidebarText, 0.08) : Colors.transparent,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.only(bottom: screenShareOn ? 2.0 : 0.0),
                  child: CallAvatar(
                    userModel: session.userModel,
                    speaking: currentCall.voiceOn.containsKey(session.sessionId),
                    muted: session.muted,
                    sharingScreen: session.sessionId == currentCall.screenOn,
                    raisedHand: session.raisedHand != 0,
                    reaction: session.reaction?.emoji,
                    size: avatarSize,
                    serverUrl: currentCall.serverUrl,
                  ),
                ),
                Text(
                  displayUsername(session.userModel, context, teammateNameDisplay) +
                      (session.sessionId == mySession.sessionId ? ' (you)' : ''),
                  style: smallerAvatar ? style.usernameShort : style.username,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
                if (session.userId == currentCall.hostId)
                  CallsBadge(type: CallsBadgeType.Host),
              ],
            ),
          );
        },
      ),
    );
  }

  dynamic getStyleSheet(CallsTheme theme) {
    return {
      'user': {
        'flexDirection': 'column',
        'alignItems': 'center',
        'margin': 4.0,
        'padding': 12.0,
        'borderRadius': 8.0,
      },
      'pressed': {
        'backgroundColor': changeOpacity(theme.sidebarText, 0.08),
      },
      'userScreenOn': {
        'marginTop': 5.0,
        'marginBottom': 0.0,
      },
      'profileScreenOn': {
        'marginBottom': 2.0,
      },
      'username': {
        'width': usernameL,
        'textAlign': 'center',
        'color': theme.buttonColor,
        ...typography('Body', 100, 'SemiBold'),
      },
      'usernameShort': {
        'marginTop': 0.0,
        'width': usernameM,
      },
    };
  }
}
