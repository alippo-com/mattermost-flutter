
import 'package:flutter/material.dart';
import 'package:mattermost_flutter/components/compass_icon.dart';
import 'package:mattermost_flutter/components/emoji.dart';
import 'package:mattermost_flutter/utils/theme.dart';

class CustomStatusEmoji extends StatelessWidget {
  final String? emoji;
  final bool isStatusSet;

  CustomStatusEmoji({this.emoji, required this.isStatusSet});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customStatusIconColor = changeOpacity(theme.iconTheme.color!, 0.64);

    return Container(
      key: Key('account.custom_status.custom_status_emoji.${isStatusSet ? emoji : "default"}'),
      child: isStatusSet && emoji != null
          ? Emoji(
              emojiName: emoji!,
              size: 20,
            )
          : CompassIcon(
              name: 'emoticon-happy-outline',
              size: 24,
              color: customStatusIconColor,
            ),
    );
  }
}
