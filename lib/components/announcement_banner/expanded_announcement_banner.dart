// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';

import 'package:mattermost_flutter/actions/local/systems.dart';
import 'package:mattermost_flutter/components/formatted_text.dart';
import 'package:mattermost_flutter/components/markdown.dart';
import 'package:mattermost_flutter/constants.dart';
import 'package:mattermost_flutter/context/server.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/hooks/device.dart';
import 'package:mattermost_flutter/screens/navigation.dart';
import 'package:mattermost_flutter/utils/button_styles.dart';
import 'package:mattermost_flutter/utils/markdown.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/typography.dart';

class ExpandedAnnouncementBanner extends HookWidget {
  final bool allowDismissal;
  final String bannerText;

  ExpandedAnnouncementBanner({
    required this.allowDismissal,
    required this.bannerText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = useTheme();
    final style = useMemo(() => getStyleSheet(theme), [theme]);
    final serverUrl = useServerUrl();
    final isTablet = useIsTablet();
    final intl = useIntl();
    final insets = MediaQuery.of(context).padding;

    void close() {
      dismissBottomSheet();
    }

    void dismissBanner() {
      dismissAnnouncement(serverUrl, bannerText);
      close();
    }

    final buttonStyles = useMemo(() {
      return {
        'okay': {
          'button': buttonBackgroundStyle(theme, 'lg', 'primary'),
          'text': buttonTextStyle(theme, 'lg', 'primary'),
        },
        'dismiss': {
          'button': [Container(margin: EdgeInsets.only(top: 10)), buttonBackgroundStyle(theme, 'lg', 'link')],
          'text': buttonTextStyle(theme, 'lg', 'link'),
        },
      };
    }, [theme]);

    final containerStyle = useMemo(() {
      return [style.container, Container(margin: EdgeInsets.only(bottom: insets.bottom + 10))];
    }, [style, insets.bottom]);

    final Scroll = useMemo(() => isTablet ? SingleChildScrollView : BottomSheetScrollView, [isTablet]);

    return Container(
      child: Column(
        children: [
          if (!isTablet)
            Text(
              intl.formatMessage('mobile.announcement_banner.title', 'Announcement'),
              style: style.title,
            ),
          Expanded(
            child: Scroll(
              child: Markdown(
                baseTextStyle: style.baseTextStyle,
                blockStyles: getMarkdownBlockStyles(theme),
                disableGallery: true,
                textStyles: getMarkdownTextStyles(theme),
                value: bannerText,
                theme: theme,
                location: Screens.BOTTOM_SHEET,
              ),
            ),
          ),
          ElevatedButton(
            style: buttonStyles['okay']['button'],
            onPressed: close,
            child: FormattedText(
              id: 'announcment_banner.okay',
              defaultMessage: 'Okay',
              style: buttonStyles['okay']['text'],
            ),
          ),
          if (allowDismissal)
            ElevatedButton(
              style: buttonStyles['dismiss']['button'],
              onPressed: dismissBanner,
              child: FormattedText(
                id: 'announcment_banner.dismiss',
                defaultMessage: 'Dismiss announcement',
                style: buttonStyles['dismiss']['text'],
              ),
            ),
        ],
      ),
    );
  }

  TextStyle getStyleSheet(Theme theme) {
    return TextStyle(
      container: BoxDecoration(
        color: theme.centerChannelColor,
        flex: 1,
      ),
      scrollContainer: BoxDecoration(
        color: theme.centerChannelColor,
        flex: 1,
        margin: EdgeInsets.only(top: 12, bottom: 24),
      ),
      baseTextStyle: TextStyle(
        color: theme.centerChannelColor,
        ...typography('Body', 100, 'Regular'),
      ),
      title: TextStyle(
        color: theme.centerChannelColor,
        ...typography('Heading', 600, 'SemiBold'),
      ),
    );
  }
}
