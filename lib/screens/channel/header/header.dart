import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:mattermost_flutter/components/compass_icon.dart';
import 'package:mattermost_flutter/components/custom_status_emoji.dart';
import 'package:mattermost_flutter/components/navigation_header.dart';
import 'package:mattermost_flutter/components/option_item.dart';
import 'package:mattermost_flutter/components/other_mentions_badge.dart';
import 'package:mattermost_flutter/components/rounded_header_context.dart';
import 'package:mattermost_flutter/constants.dart';
import 'package:mattermost_flutter/hooks/device.dart';
import 'package:mattermost_flutter/hooks/header.dart';
import 'package:mattermost_flutter/screens/navigation.dart';
import 'package:mattermost_flutter/utils/helpers.dart';
import 'package:mattermost_flutter/utils/tap.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/typography.dart';
import 'package:mattermost_flutter/components/quick_actions.dart';

class ChannelHeader extends HookWidget {
  final String channelId;
  final String channelType;
  final dynamic customStatus;
  final bool isCustomStatusEnabled;
  final bool isCustomStatusExpired;
  final String? componentId;
  final String displayName;
  final bool isOwnDirectMessage;
  final int? memberCount;
  final String searchTerm;
  final String teamId;
  final bool callsEnabledInChannel;
  final bool? isTabletView;

  ChannelHeader({
    required this.channelId,
    required this.channelType,
    this.customStatus,
    required this.isCustomStatusEnabled,
    required this.isCustomStatusExpired,
    this.componentId,
    required this.displayName,
    required this.isOwnDirectMessage,
    this.memberCount,
    required this.searchTerm,
    required this.teamId,
    required this.callsEnabledInChannel,
    this.isTabletView,
  });

  @override
  Widget build(BuildContext context) {
    final intl = useIntl();
    final isTablet = useIsTablet();
    final theme = useTheme();
    final styles = getStyleSheet(theme);
    final defaultHeight = useDefaultHeaderHeight();

    final callsAvailable = callsEnabledInChannel;
    final isDMorGM = isTypeDMorGM(channelType);
    final contextStyle = useMemo(() => {
      return {
        'top': defaultHeight,
      };
    }, [defaultHeight]);

    final leftComponent = useMemo(() {
      if (isTablet || channelId.isEmpty || teamId.isEmpty) {
        return null;
      }
      return OtherMentionsBadge(channelId: channelId);
    }, [isTablet, channelId, teamId]);

    final onBackPress = useCallback(() {
      Keyboard.dismiss();
      popTopScreen(componentId);
    }, [componentId]);

    final onTitlePress = useCallback(preventDoubleTap(() {
      String title;
      switch (channelType) {
        case General.DM_CHANNEL:
          title = intl.formatMessage('Direct message info');
          break;
        case General.GM_CHANNEL:
          title = intl.formatMessage('Group message info');
          break;
        default:
          title = intl.formatMessage('Channel info');
          break;
      }
      final closeButton = CompassIcon.getImageSourceSync('close', 24, theme.sidebarHeaderTextColor);
      final closeButtonId = 'close-channel-info';
      showModal(
        Screens.CHANNEL_INFO,
        title,
        {'channelId': channelId, 'closeButtonId': closeButtonId},
        {'topBar': {'leftButtons': [{'id': closeButtonId, 'icon': closeButton, 'testID': 'close.channel_info.button'}]}}
      );
    }), [channelId, channelType, intl, theme]);

    final onChannelQuickAction = useCallback(() {
      if (isTablet) {
        onTitlePress();
        return;
      }
      final items = callsAvailable && !isDMorGM ? 3 : 2;
      final height = CHANNEL_ACTIONS_OPTIONS_HEIGHT + SEPARATOR_HEIGHT + MARGIN + (items * ITEM_HEIGHT);
      bottomSheet({
        'title': '',
        'renderContent': () => QuickActions(
          channelId: channelId,
          callsEnabled: callsAvailable,
          isDMorGM: isDMorGM,
        ),
        'snapPoints': [1, bottomSheetSnapPoint(1, height, bottom)],
        'theme': theme,
        'closeButtonId': 'close-channel-quick-actions',
      });
    }, [channelId, isDMorGM, isTablet, onTitlePress, theme, callsAvailable]);

    final rightButtons = useMemo(() => [
      {
        'iconName': Platform.isAndroid ? 'dots-vertical' : 'dots-horizontal',
        'onPress': onChannelQuickAction,
        'buttonType': 'opacity',
        'testID': 'channel_header.channel_quick_actions.button',
      }
    ], [isTablet, searchTerm, onChannelQuickAction]);

    String title = displayName;
    if (isOwnDirectMessage) {
      title = intl.formatMessage('{displayName} (you)', {'displayName': displayName});
    }

    String? subtitle;
    if (memberCount != null) {
      subtitle = intl.formatMessage('{count, plural, one {# member} other {# members}}', {'count': memberCount});
    } else if (customStatus == null || customStatus.text == null || isCustomStatusExpired) {
      subtitle = intl.formatMessage('View info');
    }

    final subtitleCompanion = useMemo(() {
      if (memberCount != null || customStatus == null || customStatus.text == null || isCustomStatusExpired) {
        return CompassIcon(
          color: changeOpacity(theme.sidebarHeaderTextColor, 0.72),
          name: 'chevron-right',
          size: 14,
        );
      } else if (customStatus != null && customStatus.text != null) {
        return Row(
          children: [
            if (isCustomStatusEnabled && customStatus.emoji != null)
              CustomStatusEmoji(
                customStatus: customStatus,
                emojiSize: 13,
                style: styles['customStatusEmoji'],
              ),
            Container(
              alignment: Alignment.center,
              height: 15,
              child: Text(
                customStatus.text,
                style: styles['subtitle'],
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        );
      }
      return null;
    }, [memberCount, customStatus, isCustomStatusExpired]);

    return Column(
      children: [
        NavigationHeader(
          isLargeTitle: false,
          leftComponent: leftComponent,
          onBackPress: onBackPress,
          onTitlePress: onTitlePress,
          rightButtons: rightButtons,
          showBackButton: !isTablet || !(isTabletView ?? false),
          subtitle: subtitle,
          subtitleCompanion: subtitleCompanion,
          title: title,
        ),
        Container(
          height: contextStyle['top'],
          child: RoundedHeaderContext(),
        ),
      ],
    );
  }
}

Map<String, TextStyle> getStyleSheet(ThemeData theme) {
  return {
    'customStatusContainer': TextStyle(
      flexDirection: 'row',
      height: 15,
      left: Platform.isIOS ? null : -2,
      marginTop: Platform.isIOS ? null : 1,
    ),
    'customStatusEmoji': TextStyle(
      marginRight: 5,
      marginTop: Platform.isIOS ? null : -2,
    ),
    'customStatusText': TextStyle(
      alignItems: 'center',
      height: 15,
    ),
    'subtitle': TextStyle(
      color: changeOpacity(theme.sidebarHeaderTextColor, 0.72),
      ...typography('Body', 75),
      lineHeight: 12,
      marginBottom: 8,
      marginTop: 2,
      height: 13,
    ),
  };
}
