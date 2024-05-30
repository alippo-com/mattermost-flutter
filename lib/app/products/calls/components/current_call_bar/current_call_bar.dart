import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import 'calls_actions.dart';
import 'calls_alerts.dart';
import 'call_avatar.dart';
import 'call_duration.dart';
import 'message_bar.dart';
import 'unavailable_icon_wrapper.dart';
import 'calls_state.dart';
import 'calls_utils.dart';
import 'compass_icon.dart';
import 'constants.dart';
import 'navigation.dart';
import 'theme.dart';
import 'user_utils.dart';

class CurrentCallBar extends StatelessWidget {
  final String displayName;
  final CurrentCall? currentCall;
  final Map<String, CallSession> sessionsDict;
  final String teammateNameDisplay;
  final bool micPermissionsGranted;
  final bool? threadScreen;

  CurrentCallBar({
    required this.displayName,
    required this.currentCall,
    required this.sessionsDict,
    required this.teammateNameDisplay,
    required this.micPermissionsGranted,
    this.threadScreen,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final serverUrl = Provider.of<ServerUrl>(context).url;
    final callsConfig = Provider.of<CallsConfig>(context);
    final callsTheme = makeCallsTheme(theme);
    final style = _getStyleSheet(callsTheme);
    final formatMessage = Intl.message;

    void goToCallScreen() async {
      final options = {
        'layout': {
          'backgroundColor': '#000',
          'componentBackgroundColor': '#000',
          'orientation': allOrientations,
        },
        'topBar': {
          'background': {
            'color': '#000',
          },
          'visible': Platform.isAndroid,
        },
      };
      final title = formatMessage('Call');
      await dismissAllModalsAndPopToScreen(Screens.CALL, title, {'fromThreadScreen': threadScreen}, options);
    }

    void leaveCallHandler() {
      leaveCall();
    }

    final mySession = currentCall?.sessions[currentCall!.mySessionId];

    final talkingUsers = currentCall?.voiceOn.keys.toList() ?? [];
    final speaker = talkingUsers.isNotEmpty ? talkingUsers[0] : '';
    Widget talkingMessage = Text(
      formatMessage('No one is talking'),
      style: style['speakingUser'],
    );

    if (speaker.isNotEmpty) {
      talkingMessage = Text.rich(
        TextSpan(
          text: displayUsername(sessionsDict[speaker]!.userModel, Intl.getCurrentLocale(), teammateNameDisplay),
          style: style['speakingUser'],
          children: [
            TextSpan(
              text: ' ${formatMessage('is talking...')}',
              style: style['speakingPostfix'],
            ),
          ],
        ),
      );
    }

    void muteUnmute() {
      if (mySession?.muted == true) {
        unmuteMyself();
      } else {
        muteMyself();
      }
    }

    final micPermissionsError = !micPermissionsGranted && !(currentCall?.micPermissionsErrorDismissed ?? false);

    final isHost = currentCall?.hostId == mySession?.userId;
    if (currentCall?.recState?.startAt != null && currentCall?.recState?.endAt == null) {
      recordingAlert(isHost, callsConfig.EnableTranscriptions, context);
    }

    if (isHost && currentCall?.recState?.startAt != null && currentCall.recState.endAt != null) {
      recordingWillBePostedAlert(context);
    }

    if (isHost && currentCall?.recState?.err != null) {
      recordingErrorAlert(context);
    }

    return Column(
      children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: callsTheme.callsBg,
            borderRadius: BorderRadius.circular(8),
          ),
          child: InkWell(
            onTap: goToCallScreen,
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: changeOpacity(theme.buttonColor, 0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: changeOpacity(theme.buttonColor, 0.16),
                  width: 2,
                ),
              ),
              height: CURRENT_CALL_BAR_HEIGHT,
              child: Row(
                children: [
                  if (speaker.isEmpty)
                    Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        color: changeOpacity(theme.buttonColor, 0.08),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: EdgeInsets.all(2),
                      margin: EdgeInsets.symmetric(horizontal: 6),
                    ),
                  CallAvatar(
                    userModel: sessionsDict[speaker]?.userModel,
                    speaking: speaker.isNotEmpty,
                    serverUrl: currentCall?.serverUrl ?? '',
                    size: speaker.isNotEmpty ? 40 : 24,
                  ),
                  SizedBox(width: 6),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        talkingMessage,
                        Text(
                          '~$displayName',
                          style: style['channelAndTime'],
                        ),
                        CallDuration(
                          startTime: currentCall?.startTime ?? DateTime.now(),
                          updateIntervalInSeconds: 1,
                          style: style['channelAndTime'],
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      InkWell(
                        onTap: muteUnmute,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: mySession?.muted == true
                                ? changeOpacity(theme.buttonColor, 0.08)
                                : theme.onlineIndicator,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: UnavailableIconWrapper(
                              name: mySession?.muted == true ? 'microphone-off' : 'microphone',
                              size: 24,
                              unavailable: !micPermissionsGranted,
                              style: style['micIcon'],
                            ),
                          ),
                        ),
                      ),
                      VerticalDivider(
                        color: changeOpacity(theme.buttonColor, 0.16),
                        width: 1,
                        thickness: 1,
                        indent: 4,
                        endIndent: 4,
                      ),
                      InkWell(
                        onTap: leaveCallHandler,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: theme.dndIndicator,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: CompassIcon(
                              name: 'phone-hangup',
                              size: 24,
                              style: style['hangupIcon'],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        if (micPermissionsError)
          MessageBar(
            type: MessageType.microphone,
            onDismiss: () => setMicPermissionsErrorDismissed(),
          ),
        if (currentCall?.callQualityAlert == true)
          MessageBar(
            type: MessageType.callQuality,
            onDismiss: () => setCallQualityAlertDismissed(),
          ),
      ],
    );
  }

  Map<String, dynamic> _getStyleSheet(CallsTheme theme) {
    return {
      'wrapper': {
        'marginRight': 8.0,
        'marginLeft': 8.0,
        'backgroundColor': theme.callsBg,
        'borderRadius': 8.0,
      },
      'container': {
        'flexDirection': 'row',
        'alignItems': 'center',
        'backgroundColor': changeOpacity(theme.buttonColor, 0.08),
        'borderRadius': 8.0,
        'borderWidth': 2.0,
        'borderColor': changeOpacity(theme.buttonColor, 0.16),
        'width': '100%',
        'paddingTop': 8.0,
        'paddingRight': 12.0,
        'paddingBottom': 8.0,
        'paddingLeft': 6.0,
        'height': CURRENT_CALL_BAR_HEIGHT,
      },
      'avatarOutline': {
        'height': 40.0,
        'width': 40.0,
        'borderRadius': 20.0,
        'backgroundColor': changeOpacity(theme.buttonColor, 0.08),
        'padding': 2.0,
        'marginRight': 6.0,
        'marginLeft': 6.0,
      },
      'pressable': {
        'zIndex': 10,
      },
      'text': {
        'flexDirection': 'column',
        'paddingLeft': 6.0,
        'gap': 2.0,
      },
      'speakingUser': {
        'color': theme.buttonColor,
        'fontWeight': FontWeight.w600,
        'fontSize': 16.0,
      },
      'speakingPostfix': {
        'fontWeight': FontWeight.w400,
        'fontSize': 16.0,
      },
      'channelAndTime': {
        'color': changeOpacity(theme.buttonColor, 0.56),
        'fontWeight': FontWeight.w400,
        'fontSize': 14.0,
      },
      'separator': {
        'color': changeOpacity(theme.buttonColor, 0.16),
        'width': 1.0,
        'height': 24.0,
      },
      'button': {
        'marginRight': 4.0,
      },
      'micIcon': {
        'color': theme.buttonColor,
        'size': 24.0,
      },
      'hangupIcon': {
        'color': theme.buttonColor,
        'size': 24.0,
      },
    };
  }
}
