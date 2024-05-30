
import 'package:flutter/material.dart';
import 'package:mattermost_flutter/actions/app/global.dart';
import 'package:mattermost_flutter/constants/push_proxy.dart';
import 'package:mattermost_flutter/store/ephemeral_store.dart';
import 'security.dart';

import 'package:intl/intl.dart';

String pushDisabledInServerAck(String serverUrl) {
  final extractedDomain = urlSafeBase64Encode(serverUrl);
  return getPushDisabledInServerAcknowledged(extractedDomain);
}

Future<void> canReceiveNotifications(String serverUrl, String verification, Intl intl, BuildContext context) async {
  final hasAckNotification = await pushDisabledInServerAck(serverUrl);

  switch (verification) {
    case PUSH_PROXY_RESPONSE_NOT_AVAILABLE:
      EphemeralStore.setPushProxyVerificationState(serverUrl, PUSH_PROXY_STATUS_NOT_AVAILABLE);
      if (!hasAckNotification) {
        alertPushProxyError(intl, context, serverUrl: serverUrl);
      }
      break;
    case PUSH_PROXY_RESPONSE_UNKNOWN:
      EphemeralStore.setPushProxyVerificationState(serverUrl, PUSH_PROXY_STATUS_UNKNOWN);
      alertPushProxyUnknown(intl, context);
      break;
    default:
      EphemeralStore.setPushProxyVerificationState(serverUrl, PUSH_PROXY_STATUS_VERIFIED);
  }
}

Future<void> handleAlertResponse(int buttonIndex, BuildContext context, {String serverUrl}) async {
  if (buttonIndex == 0) {
    // User clicked "Okay" acknowledging that the push notifications are disabled on that server
    await storePushDisabledInServerAcknowledged(urlSafeBase64Encode(serverUrl));
  }
}

void alertPushProxyError(Intl intl, BuildContext context, {String serverUrl}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(intl.message(
          id: 'alert.push_proxy_error.title',
          defaultMessage: 'Notifications cannot be received from this server',
        )),
        content: Text(intl.message(
          id: 'alert.push_proxy_error.description',
          defaultMessage: 'Due to the configuration of this server, notifications cannot be received in the mobile app. Contact your system admin for more information.',
        )),
        actions: <Widget>[
          TextButton(
            child: Text(intl.message(
              id: 'alert.push_proxy.button',
              defaultMessage: 'Okay',
            )),
            onPressed: () => handleAlertResponse(0, context, serverUrl: serverUrl),
          ),
        ],
      );
    },
  );
}

void alertPushProxyUnknown(Intl intl, BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(intl.message(
          id: 'alert.push_proxy_unknown.title',
          defaultMessage: 'Notifications could not be received from this server',
        )),
        content: Text(intl.message(
          id: 'alert.push_proxy_unknown.description',
          defaultMessage: 'This server was unable to receive push notifications for an unknown reason. This will be attempted again next time you connect.',
        )),
        actions: <Widget>[
          TextButton(
            child: Text(intl.message(
              id: 'alert.push_proxy.button',
              defaultMessage: 'Okay',
            )),
          ),
        ],
      );
    },
  );
}
