import 'package:flutter/material.dart';
import 'package:mattermost_flutter/components/compass_icon.dart';
import 'package:mattermost_flutter/components/option_box.dart';
import 'package:mattermost_flutter/components/slide_up_panel_item.dart';
import 'package:mattermost_flutter/constants/screens.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/screens/navigation.dart';
import 'package:intl/intl.dart';

class InfoBox extends StatelessWidget {
  final String channelId;
  final BoxDecoration? containerStyle;
  final bool showAsLabel;
  final String? testID;

  InfoBox({
    required this.channelId,
    this.containerStyle,
    this.showAsLabel = false,
    this.testID,
  });

  @override
  Widget build(BuildContext context) {
    final intl = Intl.message;
    final theme = useTheme(context);

    void onViewInfo() async {
      await dismissBottomSheet(context);
      final title = intl('screens.channel_info', name: 'Channel Info');
      final closeButton = CompassIcon.getImageSourceSync('close', 24, theme.sidebarHeaderTextColor);
      final closeButtonId = 'close-channel-info';

      final options = {
        'topBar': {
          'leftButtons': [
            {
              'id': closeButtonId,
              'icon': closeButton,
              'testID': 'close.channel_info.button',
            }
          ],
        }
      };
      showModal(context, Screens.CHANNEL_INFO, title, {'channelId': channelId, 'closeButtonId': closeButtonId}, options);
    }

    if (showAsLabel) {
      return SlideUpPanelItem(
        leftIcon: Icons.info_outline,
        onPress: onViewInfo,
        testID: testID,
        text: intl('channel_header.info', name: 'View info'),
      );
    }

    return OptionBox(
      containerStyle: containerStyle,
      iconName: Icons.info_outline,
      onPress: onViewInfo,
      testID: testID,
      text: intl('intro.channel_info', name: 'Info'),
    );
  }
}
