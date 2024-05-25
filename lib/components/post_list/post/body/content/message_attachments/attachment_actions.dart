
// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:mattermost_flutter/components/post_list/post/body/content/message_attachments/action_button.dart';
import 'package:mattermost_flutter/components/post_list/post/body/content/message_attachments/action_menu.dart';
import 'package:mattermost_flutter/types/types.dart';

class AttachmentActions extends StatelessWidget {
  final List<PostAction> actions;
  final String postId;
  final ThemeData theme;

  const AttachmentActions({
    Key? key,
    required this.actions,
    required this.postId,
    required this.theme,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> content = [];

    for (var action in actions) {
      if (action.id == null || action.name == null) {
        continue;
      }

      switch (action.type) {
        case 'select':
          content.add(
            ActionMenu(
              key: Key(action.id),
              id: action.id,
              name: action.name,
              dataSource: action.dataSource,
              defaultOption: action.defaultOption,
              options: action.options,
              postId: postId,
              disabled: action.disabled,
            ),
          );
          break;
        case 'button':
        default:
          content.add(
            ActionButton(
              key: Key(action.id),
              id: action.id,
              cookie: action.cookie,
              name: action.name,
              postId: postId,
              disabled: action.disabled,
              buttonColor: action.style,
              theme: theme,
            ),
          );
          break;
      }
    }

    return content.isNotEmpty ? Column(children: content) : SizedBox.shrink();
  }
}
