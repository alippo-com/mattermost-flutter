import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:mattermost_flutter/components/call_notification.dart';
import 'package:mattermost_flutter/components/calls_badge.dart';
import 'package:mattermost_flutter/components/captions.dart';
import 'package:mattermost_flutter/components/emoji_list.dart';
import 'package:mattermost_flutter/components/formatted_text.dart';
import 'package:mattermost_flutter/components/unavailable_icon_wrapper.dart';
import 'package:mattermost_flutter/screens/participant_card.dart';
import 'package:mattermost_flutter/screens/raised_hand_banner.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/typography.dart';
import 'package:mattermost_flutter/utils/navigation.dart';
import 'package:mattermost_flutter/constants.dart';
import 'package:mattermost_flutter/types.dart';

class CallScreen extends HookWidget {
  final String componentId;
  final CurrentCall? currentCall;
  final Map<String, CallSession> sessionsDict;
  final bool micPermissionsGranted;
  final String teammateNameDisplay;
  final bool fromThreadScreen;

  CallScreen({
    required this.componentId,
    required this.currentCall,
    required this.sessionsDict,
    required this.micPermissionsGranted,
    required this.teammateNameDisplay,
    this.fromThreadScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = useTheme();
    final intl = useIntl();
    final isTablet = useIsTablet();
    final serverUrl = useServerUrl();
    final callsConfig = useCallsConfig(serverUrl);
    final incomingCalls = useIncomingCalls();
    final showControlsInLandscape = useState(false);
    final showReactions = useState(false);
    final showCC = useState(false);
    final callsTheme = useMemo(() => makeCallsTheme(theme), [theme]);
    final style = getStyleSheet(callsTheme);
    final centerUsers = useState(false);
    final layout = useState<Rect?>(null);
    final contentOverflow = useState(false);
    final previousNumSessions = useState(0);

    final mySession = currentCall?.sessions[currentCall.mySessionId];
    final micPermissionsError = !micPermissionsGranted && !currentCall?.micPermissionsErrorDismissed;
    final screenShareOn = currentCall?.screenOn ?? false;
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    final smallerAvatar = isLandscape || screenShareOn || showCC.value || contentOverflow.value;
    final avatarSize = smallerAvatar ? avatarM : avatarL;
    final numSessions = sessionsDict.length;
    final showIncomingCalls = incomingCalls.incomingCalls.isNotEmpty;

    useEffect(() {
      mergeNavigationOptions('Call', {
        layout: {
          componentBackgroundColor: callsTheme.callsBg,
          orientation: allOrientations,
        },
        topBar: {
          visible: false,
        },
      });
      if (Platform.isIOS) {
        NativeModules.SplitView.unlockOrientation();
      }

      return () {
        setScreensOrientation(isTablet);
        if (Platform.isIOS && !isTablet) {
          NativeModules.SplitView.lockPortrait();
        }
        freezeOtherScreens(false);
      };
    }, []);

    // Add other hooks and functions similarly...

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Add other widgets similarly...
          ],
        ),
      ),
    );
  }

// Add other functions and styles similarly...
}

Map<String, dynamic> getStyleSheet(CallsTheme theme) {
  return {
    'wrapper': {
      'flex': 1,
      'backgroundColor': theme.callsBg,
    },
    'container': {
      // Add other styles similarly...
    },
    // Add other styles similarly...
  };
}
