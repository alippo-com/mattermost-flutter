import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:intl/intl.dart';
import 'package:moment/moment.dart';

class CallNotification extends HookWidget {
  final List<ServersModel> servers;
  final IncomingCallNotification incomingCall;
  final String currentUserId;
  final String teammateNameDisplay;
  final List<ChannelMembershipModel>? members;
  final bool? onCallsScreen;

  CallNotification({
    required this.servers,
    required this.incomingCall,
    required this.currentUserId,
    required this.teammateNameDisplay,
    this.members,
    this.onCallsScreen,
  });

  @override
  Widget build(BuildContext context) {
    final intl = useIntl();
    final theme = useTheme();
    final style = getStyleSheet(theme);
    final serverUrl = useServerUrl();
    final moreThanOneServer = servers.length > 1;
    final serverName = useState<String>('');

    useEffect(() {
      final channelMembers = members?.where((m) => m.userId != currentUserId).toList();
      if (channelMembers == null || channelMembers.isEmpty) {
        fetchProfilesInChannel(serverUrl, incomingCall.channelID, currentUserId, false);
      }
    }, []);

    useEffect(() {
      if (moreThanOneServer) {
        getServerDisplayName(incomingCall.serverUrl).then((name) => serverName.value = name);
      }
    }, [moreThanOneServer, incomingCall.serverUrl]);

    final onContainerPress = useCallback(() async {
      if (incomingCall.serverUrl != serverUrl) {
        await DatabaseManager.setActiveServerDatabase(incomingCall.serverUrl);
        await WebsocketManager.initializeClient(incomingCall.serverUrl);
      }
      switchToChannelById(incomingCall.serverUrl, incomingCall.channelID);
    }, [incomingCall, serverUrl]);

    final onDismissPress = useCallback(() {
      removeIncomingCall(serverUrl, incomingCall.callID, incomingCall.channelID);
      dismissIncomingCall(incomingCall.serverUrl, incomingCall.channelID);
    }, [incomingCall]);

    final message = incomingCall.type == ChannelType.DM
        ? RichText(
      text: TextSpan(
        text: intl.formatMessage('mobile.calls_incoming_dm', {
          'name': displayUsername(incomingCall.callerModel, intl.locale, teammateNameDisplay),
        }),
        style: style.text,
        children: [
          TextSpan(
            text: displayUsername(incomingCall.callerModel, intl.locale, teammateNameDisplay),
            style: style.boldText,
          ),
        ],
      ),
    )
        : RichText(
      text: TextSpan(
        text: intl.formatMessage('mobile.calls_incoming_gm', {
          'name': displayUsername(incomingCall.callerModel, intl.locale, teammateNameDisplay),
          'num': (members?.length ?? 2) - 1,
        }),
        style: style.text,
        children: [
          TextSpan(
            text: displayUsername(incomingCall.callerModel, intl.locale, teammateNameDisplay),
            style: style.boldText,
          ),
          TextSpan(
            text: intl.plural((members?.length ?? 2) - 1, one: '1 other', other: '{count} others'),
            style: style.boldText,
          ),
        ],
      ),
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        color: theme.onlineIndicator,
        boxShadow: [
          BoxShadow(
            color: theme.centerChannelColor.withOpacity(0.12),
            offset: Offset(0, 6),
            blurRadius: 4.0,
          ),
        ],
      ),
      child: GestureDetector(
        onTap: onContainerPress,
        child: Container(
          padding: const EdgeInsets.all(4.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            color: Colors.black.withOpacity(0.16),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundImage: NetworkImage(incomingCall.callerModel.profilePictureUrl),
              ),
              SizedBox(width: 8.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    message,
                    if (moreThanOneServer)
                      Text(
                        serverName.value,
                        style: style.textServerName,
                      ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, color: theme.buttonColor.withOpacity(0.56)),
                onPressed: onDismissPress,
              ),
            ],
          ),
        ),
      ),
    );
  }

  TextStyle getTextStyle(Theme theme) {
    return TextStyle(
      fontSize: 14,
      color: theme.buttonColor,
    );
  }

  TextStyle getBoldTextStyle(Theme theme) {
    return TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.bold,
      color: theme.buttonColor,
    );
  }

  TextStyle getTextServerNameStyle(Theme theme) {
    return TextStyle(
      fontSize: 16,
      color: theme.buttonColor.withOpacity(0.72),
      textTransform: TextTransform.uppercase,
    );
  }

  TextStyle getTextStyleWithOpacity(Theme theme, double opacity) {
    return TextStyle(
      fontSize: 14,
      color: theme.buttonColor.withOpacity(opacity),
    );
  }

  TextStyle getBoldTextStyleWithOpacity(Theme theme, double opacity) {
    return TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.bold,
      color: theme.buttonColor.withOpacity(opacity),
    );
  }

  BoxDecoration getContainerDecoration(Theme theme) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(8.0),
      color: theme.onlineIndicator,
      boxShadow: [
        BoxShadow(
          color: theme.centerChannelColor.withOpacity(0.12),
          offset: Offset(0, 6),
          blurRadius: 4.0,
        ),
      ],
    );
  }
}
