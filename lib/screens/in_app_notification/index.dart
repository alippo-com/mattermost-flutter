import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:mattermost_flutter/screens/autocomplete.dart';
import 'package:mattermost_flutter/components/error_text.dart';
import 'package:mattermost_flutter/components/floating_text_input_label.dart';
import 'package:mattermost_flutter/components/formatted_text.dart';
import 'package:mattermost_flutter/components/loading.dart';
import 'package:mattermost_flutter/components/option_item.dart';
import 'package:mattermost_flutter/constants/general.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/typography.dart';

class InAppNotification extends StatefulWidget {
  final String componentId;
  final dynamic notification;
  final String? serverName;
  final String serverUrl;

  const InAppNotification({
    Key? key,
    required this.componentId,
    required this.notification,
    this.serverName,
    required this.serverUrl,
  }) : super(key: key);

  @override
  _InAppNotificationState createState() => _InAppNotificationState();
}

class _InAppNotificationState extends State<InAppNotification> {
  late bool animate;
  Timer? dismissTimer;
  late double initial;
  late bool isTablet;
  late EdgeInsets insets;

  @override
  void initState() {
    super.initState();
    animate = false;
    initial = -130.0;
    isTablet = useIsTablet();
    insets = EdgeInsets.zero;

    if (Platform.isIOS) {
      insets = MediaQuery.of(context).viewPadding;
    }

    dismissTimer = Timer(Duration(milliseconds: 5000), () {
      if (!tapped) {
        animateDismissOverlay();
      }
    });
  }

  @override
  void dispose() {
    dismissTimer?.cancel();
    super.dispose();
  }

  void animateDismissOverlay() {
    dismissTimer?.cancel();
    setState(() {
      animate = true;
    });
    dismissTimer = Timer(Duration(seconds: 1), dismiss);
  }

  void dismiss() {
    dismissTimer?.cancel();
    Navigator.of(context).pop(widget.componentId);
  }

  void notificationTapped() {
    tapped = true;
    dismiss();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<Theme>();
    final styles = _getStyleSheet(theme);

    final message = widget.notification['payload']['body'] ?? widget.notification['payload']['message'];
    final database = DatabaseManager.serverDatabases[widget.serverUrl]?.database;

    return Scaffold(
      body: SafeArea(
        child: GestureDetector(
          onTap: notificationTapped,
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300),
            transform: Matrix4.translationValues(0, animate ? -130 : initial, 0),
            margin: EdgeInsets.only(top: insets.top),
            decoration: BoxDecoration(
              color: Color(0xDD000000),
              borderRadius: BorderRadius.circular(12),
            ),
            width: isTablet ? 500 : MediaQuery.of(context).size.width * 0.95,
            padding: EdgeInsets.all(10),
            child: Row(
              children: [
                if (database != null)
                  Icon(
                    database: database,
                    fromWebhook: widget.notification['payload']['from_webhook'] == 'true',
                    overrideIconUrl: widget.notification['payload']['override_icon_url'],
                    senderId: widget.notification['payload']['sender_id'] ?? '',
                    serverUrl: widget.serverUrl,
                    useUserIcon: widget.notification['payload']['use_user_icon'] == 'true',
                  ),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Title(channelName: widget.notification['payload']['channel_name'] ?? ''),
                      SizedBox(height: 5),
                      Text(
                        message,
                        style: TextStyle(color: Colors.white, fontSize: 13, fontFamily: 'OpenSans'),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (widget.serverName != null)
                        Server(serverName: widget.serverName!),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Map<String, TextStyle> _getStyleSheet(Theme theme) {
    return {
      'container': TextStyle(
        flex: 1,
      ),
      'scrollView': TextStyle(
        paddingVertical: 32,
        paddingHorizontal: 20,
      ),
      'errorContainer': TextStyle(
        width: '100%',
      ),
      'errorWrapper': TextStyle(
        justifyContent: 'center',
        alignItems: 'center',
      ),
      'loading': TextStyle(
        flex: 1,
        alignItems: 'center',
        justifyContent: 'center',
      ),
      'makePrivateContainer': TextStyle(
        marginBottom: 32,
      ),
      'fieldContainer': TextStyle(
        marginBottom: 24,
      ),
      'helpText': TextStyle(
        ...typography('Body', 75, 'Regular'),
        color: changeOpacity(theme.centerChannelColor, 0.5),
        marginTop: 8,
      ),
    };
  }
}
