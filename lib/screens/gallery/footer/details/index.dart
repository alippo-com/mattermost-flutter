import 'package:flutter/material.dart';
import 'package:mattermost_flutter/components/formatted_text.dart';
import 'package:mattermost_flutter/types/typography.dart';

class Details extends StatelessWidget {
  final String channelName;
  final bool isDirectChannel;
  final bool ownPost;
  final String userDisplayName;

  Details({
    required this.channelName,
    required this.isDirectChannel,
    required this.ownPost,
    required this.userDisplayName,
  });

  @override
  Widget build(BuildContext context) {
    final displayName = {'displayName': userDisplayName};
    final channelDisplayName = {'channelName': '${isDirectChannel ? '@' : '~'}$channelName'};

    Widget userElement = Text(
      userDisplayName,
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
      style: typography('Body', 200, 'SemiBold').copyWith(color: Colors.white),
    );

    if (ownPost) {
      userElement = FormattedText(
        id: 'channel_header.directchannel.you',
        defaultMessage: '{displayName} (you)',
        values: displayName,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
        style: typography('Body', 200, 'SemiBold').copyWith(color: Colors.white),
      );
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          userElement,
          if (channelName.isNotEmpty)
            FormattedText(
              id: 'gallery.footer.channel_name',
              defaultMessage: 'Shared in {channelName}',
              values: channelDisplayName,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: typography('Body', 75).copyWith(
                color: Colors.white.withOpacity(0.56),
                marginTop: 3,
              ),
            ),
        ],
      ),
    );
  }
}
