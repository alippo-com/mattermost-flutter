import 'package:flutter/material.dart';
import 'package:mattermost_flutter/components/custom_status/custom_status_emoji.dart';
import 'package:mattermost_flutter/types/emoji_common_style.dart';

class CustomStatus extends StatelessWidget {
  final UserCustomStatus customStatus;
  final bool customStatusExpired;
  final bool isCustomStatusEnabled;
  final EmojiCommonStyle style;

  CustomStatus({
    required this.customStatus,
    required this.customStatusExpired,
    required this.isCustomStatusEnabled,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    final showCustomStatusEmoji = isCustomStatusEnabled && customStatus.emoji != null && !customStatusExpired;

    if (!showCustomStatusEmoji) {
      return Container();
    }

    return CustomStatusEmoji(
      customStatus: customStatus,
      style: style,
    );
  }
}
