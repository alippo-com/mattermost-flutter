
// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:mattermost_flutter/components/autocomplete_selector.dart';
import 'package:mattermost_flutter/utils/log.dart';
import 'package:mattermost_flutter/actions/remote/apps.dart';
import 'package:mattermost_flutter/context/server.dart';
import 'package:mattermost_flutter/hooks/apps.dart';
import 'package:mattermost_flutter/queries/servers/channel.dart';
import 'package:mattermost_flutter/types/database/models/servers/post.dart';
import 'package:provider/provider.dart';

class MenuBinding extends StatefulWidget {
  final AppBinding binding;
  final String currentTeamId;
  final PostModel post;
  final String? teamID;

  const MenuBinding({
    Key? key,
    required this.binding,
    required this.currentTeamId,
    required this.post,
    this.teamID,
  }) : super(key: key);

  @override
  _MenuBindingState createState() => _MenuBindingState();
}

class _MenuBindingState extends State<MenuBinding> {
  String? selected;
  late final String serverUrl;

  @override
  void initState() {
    super.initState();
    serverUrl = context.read<ServerUrlProvider>().serverUrl;
  }

  @override
  Widget build(BuildContext context) {
    final onCallResponse = (AppCallResponse callResp, String message) {
      postEphemeralCallResponseForPost(serverUrl, callResp, message, widget.post);
    };

    final appContext = {
      'channel_id': widget.post.channelId,
      'team_id': widget.teamID ?? widget.currentTeamId,
      'post_id': widget.post.id,
      'root_id': widget.post.rootId ?? widget.post.id,
    };

    final config = {
      'onSuccess': onCallResponse,
      'onError': onCallResponse,
    };

    final handleBindingSubmit = useAppBinding(appContext, config);

    final onSelect = (SelectedDialogOption picked) async {
      if (picked == null || picked is List) {
        return;
      }
      setState(() {
        selected = picked.value;
      });

      final bind = widget.binding.bindings?.firstWhere((b) => b.location == picked.value, orElse: () {
        logDebug('Trying to select element not present in binding.');
        return null;
      });

      if (bind != null) {
        final finish = await handleBindingSubmit(bind);
        finish();
      }
    };

    final options = widget.binding.bindings
        ?.map((b) => PostActionOption(text: b.label, value: b.location ?? ''))
        .toList();

    return AutocompleteSelector(
      placeholder: widget.binding.label,
      options: options ?? [],
      selected: selected,
      onSelected: onSelect,
      testID: 'embedded_binding.${widget.binding.location}',
    );
  }
}
