
import 'package:flutter/material.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/utils/strings.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/typography.dart';
import 'package:mattermost_flutter/components/custom_status.dart';

class ChannelBody extends StatelessWidget {
  final String displayName;
  final String teamDisplayName;
  final String channelName;
  final String? teammateId;
  final bool isMuted;
  final TextStyle textStyles;
  final String testId;

  ChannelBody({
    required this.displayName,
    required this.channelName,
    required this.teamDisplayName,
    this.teammateId,
    required this.isMuted,
    required this.textStyles,
    required this.testId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = useTheme(context);
    final isTablet = useIsTablet(context);
    final nonBreakingDisplayName = nonBreakingString(displayName);
    final channelText = Text(
      nonBreakingDisplayName + (channelName.isNotEmpty ? ' ~${channelName}' : ''),
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
      style: textStyles.copyWith(flexStyle),
    );

    if (teamDisplayName.isNotEmpty) {
      final teamText = Text(
        (isTablet ? ' ' : '') + nonBreakingString(teamDisplayName),
        overflow: isTablet ? null : TextOverflow.ellipsis,
        maxLines: isTablet ? null : 1,
        style: textStyles.copyWith(flexStyle).merge(isMuted ? getTeamNameMutedStyle(theme) : getTeamNameStyle(theme)),
      );

      if (isTablet) {
        return Text(
          nonBreakingDisplayName + teamText.data!,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          style: textStyles.copyWith(flexStyle),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          channelText,
          teamText,
        ],
      );
    }

    if (teammateId != null) {
      final customStatus = CustomStatus(
        userId: teammateId!,
        style: customStatusStyle,
      );
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          channelText,
          customStatus,
        ],
      );
    }

    return channelText;
  }
}
