import 'package:flutter/material.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/url.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
opengraph_image.dart';

class Opengraph extends StatelessWidget {
  final bool isReplyPost;
  final double? layoutWidth;
  final String location;
  final PostMetadata? metadata;
  final String postId;
  final bool showLinkPreviews;
  final Theme theme;

  Opengraph({
    required this.isReplyPost,
    this.layoutWidth,
    required this.location,
    this.metadata,
    required this.postId,
    required this.showLinkPreviews,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final intl = AppLocalizations.of(context)!;
    final link = metadata?.embeds?[0]?.url ?? '';
    final openGraphData = selectOpenGraphData(link, metadata);

    if (!showLinkPreviews || openGraphData == null) {
      return Container();
    }

    final style = getStyleSheet(theme);
    final hasImage = openGraphData.images != null &&
        openGraphData.images is List &&
        openGraphData.images!.isNotEmpty &&
        metadata?.images != null;

    void goToLink() {
      void onError() {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(intl.mobileLinkErrorTitle),
              content: Text(intl.mobileLinkErrorText),
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
      }

      tryOpenURL(link, onError);
    }

    Widget? siteName;
    if (openGraphData.siteName != null) {
      siteName = Container(
        child: Text(
          openGraphData.siteName!,
          style: style['siteName'],
          overflow: TextOverflow.ellipsis,
        ),
      );
    }

    final title = openGraphData.title ?? openGraphData.url ?? link;
    Widget? siteTitle;
    if (title != null) {
      siteTitle = GestureDetector(
        onTap: goToLink,
        child: Container(
          child: Text(
            title,
            style: style['siteTitle']!.copyWith(marginRight: isReplyPost ? 10 : 0),
            overflow: TextOverflow.ellipsis,
            maxLines: 3,
          ),
        ),
      );
    }

    Widget? siteDescription;
    if (openGraphData.description != null) {
      siteDescription = Container(
        child: Text(
          openGraphData.description!,
          style: style['siteDescription'],
          overflow: TextOverflow.ellipsis,
          maxLines: 5,
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: changeOpacity(theme.centerChannelColor, 0.2)),
        borderRadius: BorderRadius.circular(3),
      ),
      margin: EdgeInsets.only(top: 10),
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (siteName != null) siteName,
          if (siteTitle != null) siteTitle,
          if (siteDescription != null) siteDescription,
          if (hasImage)
            OpengraphImage(
              isReplyPost: isReplyPost,
              layoutWidth: layoutWidth,
              location: location,
              openGraphImages: openGraphData.images!,
              metadata: metadata,
              postId: postId,
              theme: theme,
            ),
        ],
      ),
    );
  }

  Map<String, TextStyle?> getStyleSheet(Theme theme) {
    return {
      'siteName': TextStyle(
        color: changeOpacity(theme.centerChannelColor, 0.5),
        fontSize: 12,
      ),
      'siteTitle': TextStyle(
        color: theme.linkColor,
        fontSize: 14,
      ),
      'siteDescription': TextStyle(
        color: changeOpacity(theme.centerChannelColor, 0.7),
        fontSize: 13,
      ),
    };
  }
}

class PostMetadata {
  List<Embed>? embeds;
  List<Image>? images;
}

class Embed {
  String? url;
  String? type;
  OpenGraphData? data;
}

class Image {}

class OpenGraphData {
  String? title;
  String? url;
  String? siteName;
  String? description;
  List<Image>? images;
}

OpenGraphData? selectOpenGraphData(String url, PostMetadata? metadata) {
  if (metadata?.embeds == null) {
    return null;
  }

  return metadata.embeds!.firstWhere((embed) {
    return embed.type == 'opengraph' && embed.url == url;
  }).data;
}

void tryOpenURL(String url, void Function() onError) {
  // Implementation for opening URL (using url_launcher package)
}
