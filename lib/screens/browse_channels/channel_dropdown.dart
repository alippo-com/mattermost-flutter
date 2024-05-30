// Converted from React Native to Flutter

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:mattermost_flutter/components/compass_icon.dart';
import 'package:mattermost_flutter/hooks/safe_area.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/typography.dart';

import 'dropdown_slideup.dart';

class ChannelDropdown extends HookWidget {
  final String typeOfChannels;
  final Function(String) onPress;
  final bool canShowArchivedChannels;
  final bool sharedChannelsEnabled;

  ChannelDropdown({
    required this.typeOfChannels,
    required this.onPress,
    required this.canShowArchivedChannels,
    required this.sharedChannelsEnabled,
  });

  @override
  Widget build(BuildContext context) {
    final intl = useIntl();
    final bottom = useSafeAreaInsets().bottom;
    final theme = useTheme();
    final style = getStyleFromTheme(theme);

    handleDropdownClick() {
      final renderContent = () => DropdownSlideup(
            canShowArchivedChannels: canShowArchivedChannels,
            onPress: onPress,
            sharedChannelsEnabled: sharedChannelsEnabled,
            selected: typeOfChannels,
          );

      var items = 1;
      if (canShowArchivedChannels) {
        items += 1;
      }
      if (sharedChannelsEnabled) {
        items += 1;
      }

      final itemsSnap =
          bottomSheetSnapPoint(items, ITEM_HEIGHT, bottom) + TITLE_HEIGHT;
      bottomSheet(
        context: context,
        title: intl.formatMessage(
            id: 'browse_channels.dropdownTitle', defaultMessage: 'Show'),
        renderContent: renderContent,
        snapPoints: [1, itemsSnap],
        closeButtonId: 'close',
        theme: theme,
      );
    }

    var channelDropdownText = intl.formatMessage(
        id: 'browse_channels.showPublicChannels',
        defaultMessage: 'Show: Public Channels');
    if (typeOfChannels == SHARED) {
      channelDropdownText = intl.formatMessage(
          id: 'browse_channels.showSharedChannels',
          defaultMessage: 'Show: Shared Channels');
    } else if (typeOfChannels == ARCHIVED) {
      channelDropdownText = intl.formatMessage(
          id: 'browse_channels.showArchivedChannels',
          defaultMessage: 'Show: Archived Channels');
    }

    return GestureDetector(
      onTap: handleDropdownClick,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Text(
              channelDropdownText,
              style: style['channelDropdown'],
            ),
            CompassIcon(
              name: 'menu-down',
              size: 18,
              style: style['channelDropdownIcon'],
            ),
          ],
        ),
      ),
    );
  }

  getStyleFromTheme(ThemeData theme) {
    return {
      'channelDropdown': typography('Body', 100, 'SemiBold').copyWith(
        lineHeight: 20,
        color: theme.centerChannelColor,
        marginLeft: 20,
        marginTop: 12,
        marginBottom: 4,
      ),
      'channelDropdownIcon': TextStyle(
        color: theme.centerChannelColor,
      ),
    };
  }
}
