import 'package:flutter/material.dart';
import 'package:mattermost_flutter/constants/apps.dart';
import 'package:mattermost_flutter/utils/apps.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/types/models/servers/post.dart';
import 'package:mattermost_flutter/components/embed_text.dart';
import 'package:mattermost_flutter/components/embed_title.dart';
import 'package:mattermost_flutter/components/embedded_sub_bindings.dart';

class EmbeddedBinding extends StatefulWidget {
  final AppBinding embed;
  final String location;
  final PostModel post;
  final ThemeData theme;

  EmbeddedBinding({
    required this.embed,
    required this.location,
    required this.post,
    required this.theme,
  });

  @override
  _EmbeddedBindingState createState() => _EmbeddedBindingState();
}

class _EmbeddedBindingState extends State<EmbeddedBinding> {
  late List<AppBinding> cleanedBindings;

  @override
  void initState() {
    super.initState();
    cleanedBindings = cleanBinding(widget.embed, AppBindingLocations.IN_POST)?.bindings ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final style = getStyleSheet(widget.theme);

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: changeOpacity(widget.theme.centerChannelColor, 0.15),
                width: 1,
              ),
              left: BorderSide(
                color: changeOpacity(widget.theme.linkColor, 0.6),
                width: 3,
              ),
              right: BorderSide(
                color: changeOpacity(widget.theme.centerChannelColor, 0.15),
                width: 1,
              ),
              top: BorderSide(
                color: changeOpacity(widget.theme.centerChannelColor, 0.15),
                width: 1,
              ),
            ),
          ),
          margin: EdgeInsets.only(top: 5),
          padding: EdgeInsets.all(12),
          child: Column(
            children: [
              if (widget.embed.label.isNotEmpty)
                EmbedTitle(
                  channelId: widget.post.channelId,
                  location: widget.location,
                  theme: widget.theme,
                  value: widget.embed.label,
                ),
              if (widget.embed.description?.isNotEmpty ?? false)
                EmbedText(
                  channelId: widget.post.channelId,
                  location: widget.location,
                  value: widget.embed.description!,
                  theme: widget.theme,
                ),
              if (cleanedBindings.isNotEmpty)
                EmbeddedSubBindings(
                  bindings: cleanedBindings,
                  post: widget.post,
                  theme: widget.theme,
                ),
            ],
          ),
        ),
      ],
    );
  }

  Map<String, dynamic> getStyleSheet(ThemeData theme) {
    return {
      'container': BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: changeOpacity(theme.centerChannelColor, 0.15),
            width: 1,
          ),
          left: BorderSide(
            color: changeOpacity(theme.linkColor, 0.6),
            width: 3,
          ),
          right: BorderSide(
            color: changeOpacity(theme.centerChannelColor, 0.15),
            width: 1,
          ),
          top: BorderSide(
            color: changeOpacity(theme.centerChannelColor, 0.15),
            width: 1,
          ),
        ),
        margin: EdgeInsets.only(top: 5),
        padding: EdgeInsets.all(12),
      ),
    };
  }
}

ThemeData useTheme(BuildContext context) {
  return Theme.of(context);
}
