// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:mattermost_flutter/calls/actions.dart';
import 'package:mattermost_flutter/calls/hooks.dart';
import 'package:mattermost_flutter/components/option_item.dart';
import 'package:mattermost_flutter/context/server.dart';
import 'package:mattermost_flutter/utils/tap.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ChannelInfoEnableCalls extends HookWidget {
  final String channelId;
  final bool enabled;

  ChannelInfoEnableCalls({
    required this.channelId,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    final intl = AppLocalizations.of(context)!;
    final serverUrl = useServerUrl();

    final toggleCalls = useCallback(() async {
      enableChannelCalls(serverUrl, channelId, !enabled);
    }, [serverUrl, channelId, enabled]);

    final tryOnPress = useTryCallsFunction(toggleCalls);

    final disableText = intl.mobile_calls_disable;
    final enableText = intl.mobile_calls_enable;

    return OptionItem(
      action: preventDoubleTap(tryOnPress),
      label: (enabled ? disableText : enableText),
      icon: Icons.phone,
      type: OptionItemType.defaultType,
      testID: 'channel_info.options.enable_disable_calls.option',
    );
  }
}
