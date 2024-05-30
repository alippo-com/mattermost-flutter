import 'package:flutter/material.dart';
import 'package:mattermost_flutter/components/markdown.dart';

class EmbedTitleProps {
  final String channelId;
  final String location;
  final ThemeData theme;
  final String value;

  EmbedTitleProps({
    required this.channelId,
    required this.location,
    required this.theme,
    required this.value,
  });
}

class EmbedTitle extends StatelessWidget {
  final EmbedTitleProps props;

  EmbedTitle({required this.props});

  @override
  Widget build(BuildContext context) {
    final style = _getStyleSheet(props.theme);

    return Container(
      margin: EdgeInsets.only(top: 3),
      child: Markdown(
        channelId: props.channelId,
        disableHashtags: true,
        disableAtMentions: true,
        disableChannelLink: true,
        disableGallery: true,
        location: props.location,
        autolinkedUrlSchemes: [],
        mentionKeys: [],
        theme: props.theme,
        value: props.value,
        baseTextStyle: style['title'],
        textStyles: {'link': style['link']},
      ),
    );
  }

  Map<String, TextStyle> _getStyleSheet(ThemeData theme) {
    return {
      'container': TextStyle(
        marginTop: 3,
        flex: 1,
        flexDirection: 'row',
      ),
      'title': TextStyle(
        color: theme.primaryColor,
        fontFamily: 'OpenSans-SemiBold',
        marginBottom: 5,
        fontSize: 14,
        lineHeight: 20,
      ),
      'link': TextStyle(
        color: theme.colorScheme.secondary,
      ),
    };
  }
}
