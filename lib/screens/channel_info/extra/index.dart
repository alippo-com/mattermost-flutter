
// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rx_notifier/rx_notifier.dart';

import 'package:mattermost_flutter/actions/remote/apps.dart';
import 'package:mattermost_flutter/components/option_item.dart';
import 'package:mattermost_flutter/constants/apps.dart';
import 'package:mattermost_flutter/hooks/apps.dart';
import 'package:mattermost_flutter/managers/apps_manager.dart';
import 'package:mattermost_flutter/utils/tap.dart';

// Assuming this is where the types are located

class ChannelInfoAppBindings extends HookConsumerWidget {
  final String channelId;
  final String teamId;
  final String serverUrl;
  final List<AppBinding> bindings;
  final Future<void> Function() dismissChannelInfo;

  ChannelInfoAppBindings({
    required this.channelId,
    required this.teamId,
    required this.serverUrl,
    required this.bindings,
    required this.dismissChannelInfo,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onCallResponse = useCallback((AppCallResponse callResp, String message) {
      postEphemeralCallResponseForChannel(serverUrl, callResp, message, channelId);
    }, [serverUrl, channelId]);

    final contextData = useMemo(() => {
      'channel_id': channelId,
      'team_id': teamId,
    }, [channelId, teamId]);

    final config = useMemo(() => {
      'onSuccess': onCallResponse,
      'onError': onCallResponse,
    }, [onCallResponse]);

    final handleBindingSubmit = useAppBinding(contextData, config);

    final onPress = useCallback(preventDoubleTap((AppBinding binding) async {
      final submitPromise = handleBindingSubmit(binding);
      await dismissChannelInfo();

      final finish = await submitPromise;
      await finish();
    }), [handleBindingSubmit]);

    final options = bindings.map((binding) => BindingOptionItem(
      key: binding.appId + binding.location,
      binding: binding,
      onPress: onPress,
    )).toList();

    return Column(
      children: options,
    );
  }
}

class BindingOptionItem extends StatelessWidget {
  final AppBinding binding;
  final Function(AppBinding) onPress;

  BindingOptionItem({
    required this.binding,
    required this.onPress,
  });

  @override
  Widget build(BuildContext context) {
    final handlePress = useCallback(preventDoubleTap(() {
      onPress(binding);
    }), [binding, onPress]);

    return OptionItem(
      label: binding.label,
      icon: binding.icon,
      action: handlePress,
      type: 'default',
      testId: 'channel_info.options.app_binding.option.${binding.location}',
    );
  }
}

class Enhanced extends StatelessWidget {
  final String channelId;
  final String serverUrl;

  Enhanced({
    required this.channelId,
    required this.serverUrl,
  });

  @override
  Widget build(BuildContext context) {
    final database = ref.read(databaseProvider);
    final teamId = observeCurrentTeamId(database).data;
    final bindings = AppsManager.observeBindings(serverUrl, AppBindingLocations.CHANNEL_HEADER_ICON).data;

    return ChannelInfoAppBindings(
      channelId: channelId,
      teamId: teamId,
      serverUrl: serverUrl,
      bindings: bindings,
      dismissChannelInfo: () async {
        // Implement dismiss logic
      },
    );
  }
}
