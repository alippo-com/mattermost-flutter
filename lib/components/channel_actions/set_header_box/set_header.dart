
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:mattermost_flutter/components/option_box.dart';
import 'package:mattermost_flutter/constants.dart';

class SetHeaderBox extends StatelessWidget {
  final String channelId;
  final BoxDecoration? containerStyle;
  final bool isHeaderSet;
  final bool inModal;
  final String? testID;

  SetHeaderBox({
    required this.channelId,
    this.containerStyle,
    required this.isHeaderSet,
    this.inModal = false,
    this.testID,
  });

  @override
  Widget build(BuildContext context) {
    final intl = Intl.message;

    void onSetHeader() async {
      final title = intl('screens.channel_edit_header', name: 'Edit Channel Header');
      if (inModal) {
        goToScreen(Screens.CREATE_OR_EDIT_CHANNEL, title, {'channelId': channelId, 'headerOnly': true});
        return;
      }

      await dismissBottomSheet();
      showModal(Screens.CREATE_OR_EDIT_CHANNEL, title, {'channelId': channelId, 'headerOnly': true});
    }

    String text = isHeaderSet
        ? intl('channel_info.edit_header', name: 'Edit Header')
        : intl('channel_info.set_header', name: 'Set Header');

    return OptionBox(
      containerStyle: containerStyle,
      iconName: 'pencil-outline',
      onPress: onSetHeader,
      testID: testID,
      text: text,
    );
  }
}
