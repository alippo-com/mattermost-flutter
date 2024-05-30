import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mattermost_flutter/components/markdown.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/url.dart';

class AttachmentTitle extends StatelessWidget {
  final String channelId;
  final String? link;
  final String location;
  final Theme theme;
  final String? value;

  AttachmentTitle({
    required this.channelId,
    this.link,
    required this.location,
    required this.theme,
    this.value,
  });

  @override
  Widget build(BuildContext context) {
    final intl = Intl.message;
    final style = getStyleSheet(theme);

    void openLink() {
      if (link != null) {
        final onError = () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(intl('mobile.link.error.title', defaultMessage: 'Error')),
                content: Text(intl('mobile.link.error.text', defaultMessage: 'Unable to open the link.')),
                actions: <Widget>[
                  TextButton(
                    child: Text('OK'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        };

        tryOpenURL(link!, onError);
      }
    }

    Widget title;
    if (link != null) {
      title = TextButton(
        onPressed: openLink,
        child: Text(
          value ?? '',
          style: style['title'].merge(style['link']),
        ),
      );
    } else {
      title = Markdown(
        channelId: channelId,
        location: location,
        isEdited: false,
        isReplyPost: false,
        disableHashtags: true,
        disableAtMentions: true,
        disableChannelLink: true,
        disableGallery: true,
        autolinkedUrlSchemes: [],
        mentionKeys: [],
        theme: theme,
        value: value ?? '',
        baseTextStyle: style['title'],
        textStyles: {'link': style['link']},
      );
    }

    return Container(
      child: title,
      decoration: style['container'],
    );
  }

  Map<String, dynamic> getStyleSheet(Theme theme) {
    return {
      'container': BoxDecoration(
        color: theme.linkColor,
        margin: EdgeInsets.only(top: 3),
      ),
      'link': TextStyle(color: theme.linkColor),
      'title': TextStyle(
        color: theme.centerChannelColor,
        fontSize: 14,
        fontFamily: 'OpenSans-SemiBold',
        height: 20,
        margin: EdgeInsets.only(bottom: 5),
      ),
    };
  }
}
