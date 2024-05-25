import 'package:flutter/material.dart';
import 'button_binding.dart';
import 'menu_binding.dart';
import 'package:mattermost_flutter/types/database/models/servers/post.dart';

class EmbeddedSubBindingsProps {
  final List<AppBinding> bindings;
  final PostModel post;
  final ThemeData theme;

  EmbeddedSubBindingsProps({required this.bindings, required this.post, required this.theme});
}

class EmbeddedSubBindings extends StatelessWidget {
  final EmbeddedSubBindingsProps props;

  EmbeddedSubBindings({required this.props});

  @override
  Widget build(BuildContext context) {
    List<Widget> content = [];

    for (var binding in props.bindings) {
      if (binding.appId == null || !(binding.submit != null || binding.form?.submit != null || binding.form?.source != null || binding.bindings?.isNotEmpty == true)) {
        continue;
      }

      if (binding.bindings?.isNotEmpty == true) {
        content.add(
          BindingMenu(
            key: Key(binding.location),
            binding: binding,
            post: props.post,
          ),
        );
        continue;
      }

      content.add(
        ButtonBinding(
          key: Key(binding.location),
          binding: binding,
          post: props.post,
          theme: props.theme,
        ),
      );
    }

    return content.isNotEmpty ? Column(children: content) : Container();
  }
}
