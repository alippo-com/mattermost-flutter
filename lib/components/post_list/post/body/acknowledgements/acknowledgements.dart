import 'package:flutter/material.dart';
import 'package:mattermost_flutter/actions/remote/post.dart';
import 'package:mattermost_flutter/components/compass_icon.dart';
import 'package:mattermost_flutter/components/formatted_text.dart';
import 'package:mattermost_flutter/screens/bottom_sheet/content.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/typography.dart';
import 'package:mattermost_flutter/context/server.dart';
import 'package:provider/provider.dart';
import 'users_list.dart';

class Acknowledgements extends StatelessWidget {
  final String currentUserId;
  final String currentUserTimezone;
  final bool hasReactions;
  final String location;
  final PostModel post;
  final Theme theme;

  Acknowledgements({
    required this.currentUserId,
    required this.currentUserTimezone,
    required this.hasReactions,
    required this.location,
    required this.post,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;
    final serverUrl = Provider.of<Server>(context, listen: false).serverUrl;
    final height = MediaQuery.of(context).size.height;

    final style = _getStyleSheet(theme);

    final isCurrentAuthor = post.userId == currentUserId;
    final acknowledgements = post.metadata?.acknowledgements ?? [];

    final acknowledgedAt = acknowledgements.firstWhere(
      (item) => item.userId == currentUserId,
      orElse: () => null,
    )?.acknowledgedAt;

    void handleOnPress() {
      if ((acknowledgedAt != null && moreThan5minAgo(acknowledgedAt)) || isCurrentAuthor) {
        return;
      }
      if (acknowledgedAt != null) {
        unacknowledgePost(serverUrl, post.id);
      } else {
        acknowledgePost(serverUrl, post.id);
      }
    }

    void handleOnLongPress() async {
      if (acknowledgements.isEmpty) {
        return;
      }
      final userAcknowledgements = {for (var item in acknowledgements) item.userId: item.acknowledgedAt};
      final userIds = acknowledgements.map((item) => item.userId).toList();

      try {
        await fetchMissingProfilesByIds(serverUrl, userIds);
      } catch (e) {
        return;
      }

      final renderContent = () => Column(
        children: [
          if (!isTablet)
            FormattedText(
              id: 'mobile.acknowledgements.header',
              defaultMessage: 'Acknowledgements',
              style: style.listHeaderText,
            ),
          UsersList(
            channelId: post.channelId,
            location: location,
            userAcknowledgements: userAcknowledgements,
            userIds: userIds,
            timezone: currentUserTimezone,
          ),
        ],
      );

      final snapPoint1 = bottomSheetSnapPoint(
        (userIds.length > 5 ? 5 : userIds.length) * USER_ROW_HEIGHT + TITLE_HEIGHT,
        height * 0.8,
      );
      final snapPoints = [1, snapPoint1];

      bottomSheet(
        context: context,
        renderContent: renderContent,
        initialSnapIndex: 1,
        snapPoints: snapPoints,
        title: 'Acknowledgements',
        theme: theme,
      );
    }

    return Row(
      children: [
        GestureDetector(
          onTap: handleOnPress,
          onLongPress: handleOnLongPress,
          child: Container(
            decoration: BoxDecoration(
              color: acknowledgedAt != null ? theme.onlineIndicator : theme.onlineIndicator.withOpacity(0.12),
              borderRadius: BorderRadius.circular(4),
            ),
            padding: EdgeInsets.symmetric(horizontal: 8),
            height: 32,
            alignment: Alignment.center,
            child: Row(
              children: [
                CompassIcon(
                  color: acknowledgedAt != null ? Colors.white : theme.onlineIndicator,
                  name: 'check-circle-outline',
                  size: 24,
                  style: style.icon,
                ),
                if (isCurrentAuthor || acknowledgements.isNotEmpty)
                  Text(
                    '${acknowledgements.length}',
                    style: acknowledgedAt != null ? style.textActive : style.text,
                  )
                else
                  FormattedText(
                    id: 'post_priority.button.acknowledge',
                    defaultMessage: 'Acknowledge',
                    style: style.text,
                  ),
              ],
            ),
          ),
        ),
        if (hasReactions)
          Container(
            width: 1,
            height: 32,
            margin: EdgeInsets.symmetric(horizontal: 8),
            color: theme.centerChannelColor.withOpacity(0.16),
          ),
      ],
    );
  }

  TextStyle _getTextStyle(String type, double weight, String style) {
    // Implement this function to return the appropriate text style
  }

  Map<String, dynamic> _getStyleSheet(Theme theme) {
    return {
      'container': {
        'alignItems': 'center',
        'borderRadius': 4,
        'backgroundColor': theme.onlineIndicator.withOpacity(0.12),
        'flexDirection': 'row',
        'height': 32,
        'justifyContent': 'center',
        'paddingHorizontal': 8,
      },
      'containerActive': {
        'backgroundColor': theme.onlineIndicator,
      },
      'text': _getTextStyle('Body', 100, 'SemiBold').copyWith(color: theme.onlineIndicator),
      'textActive': _getTextStyle('Body', 100, 'SemiBold').copyWith(color: Colors.white),
      'icon': {'marginRight': 4},
      'divider': {
        'width': 1,
        'height': 32,
        'marginHorizontal': 8,
        'backgroundColor': theme.centerChannelColor.withOpacity(0.16),
      },
      'listHeaderText': _getTextStyle('Heading', 600, 'SemiBold').copyWith(
        marginBottom: 12,
        color: theme.centerChannelColor,
      ),
    };
  }
}
