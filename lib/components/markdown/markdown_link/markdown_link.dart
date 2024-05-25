import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mattermost_flutter/components/slide_up_panel_item.dart';
import 'package:mattermost_flutter/context/server.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/screens/navigation.dart';
import 'package:mattermost_flutter/utils/deep_link.dart';
import 'package:mattermost_flutter/utils/helpers.dart';
import 'package:mattermost_flutter/utils/tap.dart';
import 'package:mattermost_flutter/utils/url.dart';
import 'package:mattermost_flutter/types/managed_config.dart';

class MarkdownLink extends HookWidget {
  final Widget children;
  final String experimentalNormalizeMarkdownLinks;
  final String href;
  final String siteURL;
  final Function(String)? onLinkLongPress;

  MarkdownLink({
    required this.children,
    required this.experimentalNormalizeMarkdownLinks,
    required this.href,
    required this.siteURL,
    this.onLinkLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final intl = useIntl();
    final bottom = MediaQuery.of(context).padding.bottom;
    final managedConfig = useManagedConfig();
    final serverUrl = useServerUrl();
    final theme = useTheme();

    void handlePress() async {
      final url = normalizeProtocol(href);

      if (url == null) {
        return;
      }

      void onError() {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(intl.formatMessage({
                'id': 'mobile.link.error.title',
                'defaultMessage': 'Error',
              })),
              content: Text(intl.formatMessage({
                'id': 'mobile.link.error.text',
                'defaultMessage': 'Unable to open the link.',
              })),
              actions: [
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

      final match = matchDeepLink(url, serverUrl, siteURL);

      if (match != null) {
        final error = await handleDeepLink(match.url, intl);
        if (error != null) {
          tryOpenURL(match.url, onError);
        }
      } else {
        tryOpenURL(url, onError);
      }
    }

    List<Widget> parseChildren(Widget child) {
      if (child is Text && child.data != null) {
        final parsedLiteral = parseLinkLiteral(child.data!);
        return [Text(parsedLiteral)];
      }
      return [child];
    }

    void handleLongPress() {
      if (managedConfig?.copyAndPasteProtection != 'true') {
        if (onLinkLongPress != null) {
          onLinkLongPress!(href);
          return;
        }

        void renderContent(BuildContext context) {
          showModalBottomSheet(
            context: context,
            builder: (BuildContext context) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SlideUpPanelItem(
                    leftIcon: Icons.content_copy,
                    onPress: () {
                      Navigator.pop(context);
                      Clipboard.setData(ClipboardData(text: href));
                    },
                    text: intl.formatMessage({'id': 'mobile.markdown.link.copy_url', 'defaultMessage': 'Copy URL'}),
                  ),
                  SlideUpPanelItem(
                    destructive: true,
                    leftIcon: Icons.cancel,
                    onPress: () {
                      Navigator.pop(context);
                    },
                    text: intl.formatMessage({'id': 'mobile.post.cancel', 'defaultMessage': 'Cancel'}),
                  ),
                ],
              );
            },
          );
        }

        bottomSheet(
          context: context,
          closeButtonId: 'close-markdown-link',
          renderContent: renderContent,
          snapPoints: [1, bottomSheetSnapPoint(2, ITEM_HEIGHT, bottom)],
          title: intl.formatMessage({'id': 'post.options.title', 'defaultMessage': 'Options'}),
          theme: theme,
        );
      }
    }

    final renderChildren = experimentalNormalizeMarkdownLinks ? parseChildren(children) : children;

    return GestureDetector(
      onTap: handlePress,
      onLongPress: handleLongPress,
      child: renderChildren,
    );
  }
}

String parseLinkLiteral(String literal) {
  var nextLiteral = literal;

  final WWW_REGEX = RegExp(r'\b^(?:www.)', caseSensitive: false);
  if (WWW_REGEX.hasMatch(nextLiteral)) {
    nextLiteral = nextLiteral.replaceFirst(WWW_REGEX, 'www.');
  }

  final parsed = Uri.parse(nextLiteral);
  return parsed.toString();
}
