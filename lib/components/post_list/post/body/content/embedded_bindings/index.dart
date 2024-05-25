import 'package:flutter/material.dart';
import 'embedded_binding.dart';
import 'package:mattermost_flutter/types/database/models/servers/post.dart';

class EmbeddedBindingsProps {
  final String location;
  final PostModel post;
  final ThemeData theme;

  EmbeddedBindingsProps({required this.location, required this.post, required this.theme});
}

class EmbeddedBindings extends StatelessWidget {
  final EmbeddedBindingsProps props;

  EmbeddedBindings({required this.props});

  @override
  Widget build(BuildContext context) {
    List<Widget> content = [];
    List<AppBinding> embeds = props.post.props.appBindings;

    for (int i = 0; i < embeds.length; i++) {
      content.add(
        EmbeddedBinding(
          embed: embeds[i],
          location: props.location,
          key: Key('binding_' + i.toString()),
          post: props.post,
          theme: props.theme,
        ),
      );
    }

    return Container(
      child: Column(
        children: content,
      ),
    );
  }
}
