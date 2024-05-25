// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mattermost_flutter/constants.dart';
import 'package:mattermost_flutter/helpers/database.dart';
import 'package:mattermost_flutter/helpers/role.dart';
import 'package:mattermost_flutter/types.dart';
import 'package:mattermost_flutter/components/channel_info_enable_calls.dart';
import 'package:mattermost_flutter/components/channel_actions.dart';
import 'package:mattermost_flutter/components/convert_to_channel_label.dart';
import 'package:mattermost_flutter/components/app_bindings.dart';
import 'package:mattermost_flutter/components/destructive_options.dart';
import 'package:mattermost_flutter/components/extra.dart';
import 'package:mattermost_flutter/components/options.dart';
import 'package:mattermost_flutter/components/title.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/navigation.dart';

class ChannelInfoScreen extends StatelessWidget {
  final String channelId;
  final String closeButtonId;
  final AvailableScreens componentId;
  final ChannelType? type;
  final bool canEnableDisableCalls;
  final bool isCallsEnabledInChannel;
  final bool canManageMembers;
  final bool isCRTEnabled;
  final bool canManageSettings;
  final bool isGuestUser;
  final bool isConvertGMFeatureAvailable;

  ChannelInfoScreen({
    required this.channelId,
    required this.closeButtonId,
    required this.componentId,
    this.type,
    required this.canEnableDisableCalls,
    required this.isCallsEnabledInChannel,
    required this.canManageMembers,
    required this.isCRTEnabled,
    required this.canManageSettings,
    required this.isGuestUser,
    required this.isConvertGMFeatureAvailable,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeNotifier>().theme;
    final serverUrl = context.watch<ServerNotifier>().serverUrl;
    final styles = _getStyleSheet(theme);
    final callsAvailable = isCallsEnabledInChannel;

    void onPressed() {
      Navigator.of(context).pop();
    }

    final convertGMOptionAvailable = isConvertGMFeatureAvailable &&
        type == General.GM_CHANNEL &&
        !isGuestUser;

    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TitleComponent(
                channelId: channelId,
                type: type,
              ),
              ChannelActions(
                channelId: channelId,
                inModal: true,
                dismissChannelInfo: onPressed,
                callsEnabled: callsAvailable,
              ),
              Extra(channelId: channelId),
              Divider(color: theme.centerChannelColor.withOpacity(0.08)),
              Options(
                channelId: channelId,
                type: type,
                callsEnabled: callsAvailable,
                canManageMembers: canManageMembers,
                isCRTEnabled: isCRTEnabled,
                canManageSettings: canManageSettings,
              ),
              Divider(color: theme.centerChannelColor.withOpacity(0.08)),
              if (convertGMOptionAvailable) ...[
                ConvertToChannelLabel(channelId: channelId),
                Divider(color: theme.centerChannelColor.withOpacity(0.08)),
              ],
              if (canEnableDisableCalls) ...[
                ChannelInfoEnableCalls(
                  channelId: channelId,
                  enabled: isCallsEnabledInChannel,
                ),
                Divider(color: theme.centerChannelColor.withOpacity(0.08)),
              ],
              ChannelInfoAppBindings(
                channelId: channelId,
                serverUrl: serverUrl,
                dismissChannelInfo: onPressed,
              ),
              DestructiveOptions(
                channelId: channelId,
                componentId: componentId,
                type: type,
              ),
            ],
          ),
        ),
      ),
    );
  }

  _getStyleSheet(Theme theme) {
    return {
      'content': {
        'paddingHorizontal': 20,
        'paddingBottom': 16,
      },
      'flex': {
        'flex': 1,
      },
      'separator': {
        'height': 1,
        'backgroundColor': theme.centerChannelColor.withOpacity(0.08),
        'marginVertical': 8,
      },
    };
  }
}
