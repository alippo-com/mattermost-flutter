import 'package:flutter/material.dart';
import 'package:mattermost_flutter/components/tag.dart';
import 'package:mattermost_flutter/i18n.dart';

class HeaderTag extends StatelessWidget {
  final bool? isAutomation;
  final bool? isAutoResponder;
  final bool? showGuestTag;

  HeaderTag({this.isAutomation, this.isAutoResponder, this.showGuestTag});

  @override
  Widget build(BuildContext context) {
    final tagStyle = const EdgeInsets.only(
      left: 0,
      right: 5,
      bottom: 5,
    );

    if (isAutomation == true) {
      return BotTag(
        style: tagStyle,
        testID: 'post_header.bot.tag',
      );
    } else if (showGuestTag == true) {
      return GuestTag(
        style: tagStyle,
        testID: 'post_header.guest.tag',
      );
    } else if (isAutoResponder == true) {
      return Tag(
        id: t('post_info.auto_responder'),
        defaultMessage: 'Automatic Reply',
        style: tagStyle,
        testID: 'post_header.auto_responder.tag',
      );
    }

    return SizedBox.shrink();
  }
}
