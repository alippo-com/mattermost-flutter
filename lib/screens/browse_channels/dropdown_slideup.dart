
import 'package:flutter/material.dart';
import 'package:flutter_intl/flutter_intl.dart';
import 'package:mattermost_flutter/components/slide_up_panel_item.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/hooks/device.dart';
import 'package:mattermost_flutter/screens/bottom_sheet/content.dart';
import 'package:mattermost_flutter/screens/navigation.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/types.dart'; // For the Theme type

import './browse_channels.dart';

class DropdownSlideup extends StatelessWidget {
  final Function(String) onPress;
  final bool? canShowArchivedChannels;
  final bool? sharedChannelsEnabled;
  final String selected;

  DropdownSlideup({
    required this.onPress,
    this.canShowArchivedChannels,
    this.sharedChannelsEnabled,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    final intl = Intl.of(context);
    final theme = useTheme(context);
    final style = getStyleFromTheme(theme);
    final isTablet = useIsTablet(context);

    void handlePublicPress() {
      dismissBottomSheet(context);
      onPress(PUBLIC);
    }

    void handleArchivedPress() {
      dismissBottomSheet(context);
      onPress(ARCHIVED);
    }

    void handleSharedPress() {
      dismissBottomSheet(context);
      onPress(SHARED);
    }

    return BottomSheetContent(
      showButton: false,
      showTitle: !isTablet,
      testID: 'browse_channels.dropdown_slideup',
      title: intl.formatMessage(id: 'browse_channels.dropdownTitle', defaultMessage: 'Show'),
      children: [
        SlideUpPanelItem(
          onPressed: handlePublicPress,
          testID: 'browse_channels.dropdown_slideup_item.public_channels',
          text: intl.formatMessage(id: 'browse_channels.publicChannels', defaultMessage: 'Public Channels'),
          rightIcon: selected == PUBLIC ? Icons.check : null,
          rightIconStyles: style['checkIcon'],
        ),
        if (canShowArchivedChannels ?? false)
          SlideUpPanelItem(
            onPressed: handleArchivedPress,
            testID: 'browse_channels.dropdown_slideup_item.archived_channels',
            text: intl.formatMessage(id: 'browse_channels.archivedChannels', defaultMessage: 'Archived Channels'),
            rightIcon: selected == ARCHIVED ? Icons.check : null,
            rightIconStyles: style['checkIcon'],
          ),
        if (sharedChannelsEnabled ?? false)
          SlideUpPanelItem(
            onPressed: handleSharedPress,
            testID: 'browse_channels.dropdown_slideup_item.shared_channels',
            text: intl.formatMessage(id: 'browse_channels.sharedChannels', defaultMessage: 'Shared Channels'),
            rightIcon: selected == SHARED ? Icons.check : null,
            rightIconStyles: style['checkIcon'],
          ),
      ],
    );
  }

  Map<String, dynamic> getStyleFromTheme(Theme theme) {
    return {
      'checkIcon': TextStyle(color: theme.buttonBg),
    };
  }
}
