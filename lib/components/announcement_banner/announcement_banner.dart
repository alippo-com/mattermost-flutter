// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:mattermost_flutter/components/compass_icon.dart';
import 'package:mattermost_flutter/components/remove_markdown.dart';
import 'package:mattermost_flutter/constants/view.dart';
import 'package:mattermost_flutter/utils/markdown.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/typography.dart';
import 'package:mattermost_flutter/context/server.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:flutter_reanimated/flutter_reanimated.dart';
import 'package:flutter_safe_area/flutter_safe_area.dart';
import 'expanded_announcement_banner.dart';

class AnnouncementBanner extends HookWidget {
  final String bannerColor;
  final bool bannerDismissed;
  final bool bannerEnabled;
  final String bannerText;
  final String bannerTextColor;
  final bool allowDismissal;

  AnnouncementBanner({
    required this.bannerColor,
    required this.bannerDismissed,
    required this.bannerEnabled,
    this.bannerText = '',
    this.bannerTextColor = '#000',
    required this.allowDismissal,
  });

  static const CLOSE_BUTTON_ID = 'announcement-close';
  static const BUTTON_HEIGHT = 48;
  static const TITLE_HEIGHT = 42;
  static const MARGINS = 46;
  static const TEXT_CONTAINER_HEIGHT = 150;
  static const DISMISS_BUTTON_HEIGHT = BUTTON_HEIGHT + 10;
  static const SNAP_POINT_WITHOUT_DISMISS = TITLE_HEIGHT + BUTTON_HEIGHT + MARGINS + TEXT_CONTAINER_HEIGHT;

  @override
  Widget build(BuildContext context) {
    final intl = useIntl();
    final serverUrl = useServerUrl();
    final height = useSharedValue(0.0);
    final insets = useSafeAreaInsets();
    final theme = useTheme();
    final visible = useState(false);
    final style = getStyle(theme);
    final markdownTextStyles = getMarkdownTextStyles(theme);

    useEffect(() {
      visible.value = bannerEnabled && !bannerDismissed && bannerText.isNotEmpty;
    }, [bannerDismissed, bannerEnabled, bannerText]);

    useEffect(() {
      height.value = withTiming(visible.value ? ANNOUNCEMENT_BAR_HEIGHT : 0.0, duration: 200);
    }, [visible.value]);

    final bannerStyle = useAnimatedStyle(() {
      return {'height': height.value};
    });

    final bannerTextContainerStyle = useMemo(() {
      return [style.bannerTextContainer, {'color': bannerTextColor}];
    }, [style, bannerTextColor]);

    void renderContent() {
      return ExpandedAnnouncementBanner(
        allowDismissal: allowDismissal,
        bannerText: bannerText,
      );
    }

    void handlePress() {
      final title = intl.formatMessage(
        id: 'mobile.announcement_banner.title',
        defaultMessage: 'Announcement',
      );

      final snapPoint = bottomSheetSnapPoint(
        1,
        SNAP_POINT_WITHOUT_DISMISS + (allowDismissal ? DISMISS_BUTTON_HEIGHT : 0),
        insets.bottom,
      );

      bottomSheet(
        context: context,
        closeButtonId: CLOSE_BUTTON_ID,
        title: title,
        renderContent: renderContent,
        snapPoints: [1, snapPoint],
        theme: theme,
      );
    }

    void handleDismiss() {
      dismissAnnouncement(serverUrl, bannerText);
    }

    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      height: height.value,
      child: Container(
        color: theme.sidebarBg,
        child: Row(
          children: [
            if (visible.value)
              Expanded(
                child: GestureDetector(
                  onTap: handlePress,
                  child: Row(
                    children: [
                      CompassIcon(
                        color: bannerTextColor,
                        name: 'information-outline',
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      RemoveMarkdown(
                        value: bannerText,
                        textStyle: markdownTextStyles,
                        baseStyle: style.bannerText,
                      ),
                    ],
                  ),
                ),
              ),
            if (allowDismissal)
              GestureDetector(
                onTap: handleDismiss,
                child: CompassIcon(
                  color: changeOpacity(bannerTextColor, 0.56),
                  name: 'close',
                  size: 18,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> getStyle(Theme theme) {
    return {
      'background': {
        'backgroundColor': theme.sidebarBg,
        'zIndex': 1,
      },
      'bannerContainer': {
        'flex': 1,
        'paddingHorizontal': 10,
        'overflow': 'hidden',
        'flexDirection': 'row',
        'alignItems': 'center',
        'marginHorizontal': 8,
        'borderRadius': 7,
      },
      'wrapper': {
        'flexDirection': 'row',
        'flex': 1,
        'overflow': 'hidden',
      },
      'bannerTextContainer': {
        'flex': 1,
        'flexGrow': 1,
        'marginRight': 5,
        'textAlign': 'center',
      },
      'bannerText': typography('Body', 100, 'SemiBold'),
    };
  }
}
