import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mattermost_flutter/components/option_item.dart';
import 'package:mattermost_flutter/hooks/apps.dart';
import 'package:mattermost_flutter/queries/servers/channel.dart';
import 'package:mattermost_flutter/utils/post.dart';
import 'package:mattermost_flutter/utils/tap.dart';

class AppBindingsPostOptions extends HookWidget {
  final String bottomSheetId;
  final List<AppBinding> bindings;
  final PostModel post;
  final String serverUrl;
  final String teamId;

  AppBindingsPostOptions({
    required this.bottomSheetId,
    required this.serverUrl,
    required this.post,
    required this.teamId,
    required this.bindings,
  });

  @override
  Widget build(BuildContext context) {
    final onCallResponse = useCallback((AppCallResponse callResp, String message) {
      postEphemeralCallResponseForPost(serverUrl, callResp, message, post);
    }, [serverUrl, post]);

    final context = useMemo(() => AppContext(
      channelId: post.channelId,
      teamId: teamId,
      postId: post.id,
      rootId: post.rootId ?? post.id,
    ), [post, teamId]);

    final config = useMemo(() => AppBindingConfig(
      onSuccess: onCallResponse,
      onError: onCallResponse,
    ), [onCallResponse]);

    final handleBindingSubmit = useAppBinding(context, config);

    final onPress = useCallback((AppBinding binding) async {
      final submitPromise = handleBindingSubmit(binding);
      await dismissBottomSheet(bottomSheetId);

      final finish = await submitPromise;
      await finish();
    }, [bottomSheetId, handleBindingSubmit]);

    if (isSystemMessage(post)) {
      return Container();
    }

    final options = bindings.map((binding) => BindingOptionItem(
      key: binding.location,
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
  final void Function(AppBinding) onPress;

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
      testID: 'post_options.app_binding.option.${binding.location}',
    );
  }
}
