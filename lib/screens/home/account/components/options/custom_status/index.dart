
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';

import 'package:mattermost_flutter/actions/local/user.dart';
import 'package:mattermost_flutter/constants.dart';
import 'package:mattermost_flutter/context/server.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/utils/tap.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/typography.dart';

import 'custom_label.dart';
import 'custom_status_emoji.dart';

class CustomStatus extends StatefulWidget {
  final bool isTablet;
  final UserModel currentUser;

  const CustomStatus({
    Key? key,
    required this.isTablet,
    required this.currentUser,
  }) : super(key: key);

  @override
  _CustomStatusState createState() => _CustomStatusState();
}

class _CustomStatusState extends State<CustomStatus> {
  bool showRetryMessage = false;

  @override
  void initState() {
    super.initState();
    DeviceEventEmitter().addListener(SET_CUSTOM_STATUS_FAILURE, _onSetCustomStatusError);
  }

  @override
  void dispose() {
    DeviceEventEmitter().removeListener(SET_CUSTOM_STATUS_FAILURE, _onSetCustomStatusError);
    super.dispose();
  }

  void _onSetCustomStatusError() {
    setState(() {
      showRetryMessage = true;
    });
  }

  Future<void> _clearCustomStatus() async {
    setState(() {
      showRetryMessage = false;
    });

    final error = await unsetCustomStatus(context.read<ServerUrl>());
    if (error != null) {
      setState(() {
        showRetryMessage = true;
      });
      return;
    }

    updateLocalCustomStatus(context.read<ServerUrl>(), widget.currentUser, null);
  }

  void _goToCustomStatusScreen() {
    preventDoubleTap(() {
      if (widget.isTablet) {
        DeviceEventEmitter().emit(Events.ACCOUNT_SELECT_TABLET_VIEW, Screens.CUSTOM_STATUS);
      } else {
        showModal(
          context,
          Screens.CUSTOM_STATUS,
          context.read<Intl>().formatMessage(id: 'mobile.routes.custom_status', defaultMessage: 'Set a custom status'),
        );
      }
      setState(() {
        showRetryMessage = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.read<Theme>();
    final customStatus = getUserCustomStatus(widget.currentUser);
    final isCustomStatusExpired = checkCustomStatusIsExpired(widget.currentUser);
    final isStatusSet = !isCustomStatusExpired && (customStatus?.text != null || customStatus?.emoji != null);
    final styles = _getStyleSheet(theme);

    return GestureDetector(
      onTap: _goToCustomStatusScreen,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 18),
        child: Row(
          children: [
            CustomStatusEmoji(
              emoji: customStatus?.emoji,
              isStatusSet: isStatusSet,
            ),
            CustomLabel(
              customStatus: customStatus!,
              isStatusSet: isStatusSet,
              onClearCustomStatus: _clearCustomStatus,
              showRetryMessage: showRetryMessage,
            ),
          ],
        ),
      ),
    );
  }

  Map<String, TextStyle> _getStyleSheet(Theme theme) {
    return {
      'label': TextStyle(
        color: theme.centerChannelColor,
        ...typography('Body', 200),
        textAlignVertical: TextAlignVertical.center,
      ),
      'body': TextStyle(
        flexDirection: Axis.horizontal,
        marginVertical: 18,
      ),
    };
  }
}
