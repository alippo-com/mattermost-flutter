// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:mattermost_flutter/constants.dart';
import 'package:mattermost_flutter/queries/servers/channel.dart';
import 'package:mattermost_flutter/queries/servers/role.dart';
import 'package:mattermost_flutter/queries/servers/user.dart';
import 'package:mattermost_flutter/widgets/convert_private.dart';
import 'package:mattermost_flutter/utils/intl.dart';
import 'package:mattermost_flutter/utils/alert.dart';
import 'package:mattermost_flutter/utils/tap.dart';
import 'package:mattermost_flutter/components/option_item.dart';
import 'package:mattermost_flutter/context/server.dart';
import 'package:mattermost_flutter/i18n.dart';
import 'package:mattermost_flutter/utils/draft.dart';

class ConvertPrivate extends StatelessWidget {
  final bool canConvert;
  final String channelId;
  final String displayName;

  ConvertPrivate({required this.canConvert, required this.channelId, required this.displayName});

  void onConfirmConvertToPrivate(BuildContext context, String serverUrl, Intl intl) {
    final formatMessage = intl.formatMessage;
    final title = formatMessage(IntlMessage(id: t('channel_info.convert_private_title'), defaultMessage: 'Convert $displayName to a private channel?'));
    final message = formatMessage(IntlMessage(
        id: t('channel_info.convert_private_description'),
        defaultMessage:
            'When you convert $displayName to a private channel, history and membership are preserved. Publicly shared files remain accessible to anyone with the link. Membership in a private channel is by invitation only.

The change is permanent and cannot be undone.

Are you sure you want to convert $displayName to a private channel?'));

    showAlert(
      context,
      title,
      message,
      [
        AlertAction(text: formatMessage(IntlMessage(id: 'channel_info.alertNo', defaultMessage: 'No'))),
        AlertAction(
          text: formatMessage(IntlMessage(id: 'channel_info.alertYes', defaultMessage: 'Yes')),
          onPressed: () => convertToPrivate(context, serverUrl, intl),
        )
      ],
    );
  }

  void convertToPrivate(BuildContext context, String serverUrl, Intl intl) {
    preventDoubleTap(() async {
      final result = await convertChannelToPrivate(serverUrl, channelId);
      final formatMessage = intl.formatMessage;
      if (result.error != null) {
        alertErrorWithFallback(
          context,
          intl,
          result.error,
          IntlMessage(id: t('channel_info.convert_failed'), defaultMessage: 'We were unable to convert $displayName to a private channel.'),
          displayName,
          [
            AlertAction(text: formatMessage(IntlMessage(id: 'channel_info.error_close', defaultMessage: 'Close'))),
            AlertAction(
              text: formatMessage(IntlMessage(id: 'channel_info.alert_retry', defaultMessage: 'Try Again')),
              onPressed: () => convertToPrivate(context, serverUrl, intl),
            )
          ],
        );
      } else {
        showAlert(
          context,
          '',
          formatMessage(IntlMessage(id: t('channel_info.convert_private_success'), defaultMessage: '$displayName is now a private channel.')),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!canConvert) {
      return Container();
    }

    final intl = Intl.of(context);
    final serverUrl = useServerUrl(context);

    return OptionItem(
      action: () => onConfirmConvertToPrivate(context, serverUrl, intl),
      label: intl.formatMessage(IntlMessage(id: 'channel_info.convert_private', defaultMessage: 'Convert to private channel')),
      icon: Icons.lock_outline,
      type: OptionType.defaultType,
      testID: 'channel_info.options.convert_private.option',
    );
  }
}
