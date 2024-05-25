
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:mattermost_flutter/components/compass_icon.dart';
import 'package:mattermost_flutter/components/formatted_text.dart';
import 'package:mattermost_flutter/components/team_sidebar/team_list/team_item/team_icon.dart';
import 'package:mattermost_flutter/context/server.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/utils/tap.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/typography.dart';

class SelectionTeamBar extends StatelessWidget {
  final String teamId;
  final String teamDisplayName;
  final int teamLastIconUpdate;
  final String teamInviteId;
  final String serverUrl;
  final Function onLayoutContainer;
  final Future<void> Function() onClose;

  SelectionTeamBar({
    required this.teamId,
    required this.teamDisplayName,
    required this.teamLastIconUpdate,
    required this.teamInviteId,
    required this.serverUrl,
    required this.onLayoutContainer,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<Theme>(context);
    final serverDisplayName = Provider.of<ServerDisplayName>(context);

    final styles = _getStyleSheet(theme);

    void handleOnLayoutContainer(LayoutChangeEvent e) {
      onLayoutContainer(e);
    }

    Future<void> handleOnShareLink() async {
      final url = '$serverUrl/signup_user_complete/?id=$teamInviteId';
      final title = 'Join the $teamDisplayName team';
      final message = 'Here’s a link to collaborate and communicate with us on Mattermost.';
      final icon = 'data:<data_type>/<file_extension>;base64,<base64_data>';

      final options = ShareOptions(
        subject: title,
        text: '$message $url',
        linkMetadata: LinkMetadata(
          originalUrl: url,
          url: url,
          title: title,
          icon: icon,
        ),
      );

      await onClose();

      try {
        Share.shareWithResult(options);
      } catch (e) {
        // do nothing
      }
    }

    void handleShareLink() {
      preventDoubleTap(() => handleOnShareLink());
    }

    return Container(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: changeOpacity(theme.centerChannelColor, 0.04),
      ),
      child: Column(
        children: [
          GestureDetector(
            onLayout: handleOnLayoutContainer,
            child: Container(
              width: 40,
              height: 40,
              child: TeamIcon(
                id: teamId,
                displayName: teamDisplayName,
                lastIconUpdate: teamLastIconUpdate,
                selected: false,
                textColor: theme.centerChannelColor,
                backgroundColor: changeOpacity(theme.centerChannelColor, 0.16),
                testID: 'invite.team_icon',
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                teamDisplayName,
                style: styles.teamText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                serverDisplayName.value,
                style: styles.serverText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          Spacer(),
          GestureDetector(
            onTap: handleShareLink,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: changeOpacity(theme.buttonBg, 0.08),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  CompassIcon(
                    name: 'export-variant',
                    size: 18,
                    color: theme.buttonBg,
                  ),
                  SizedBox(width: 7),
                  FormattedText(
                    id: 'invite.shareLink',
                    defaultMessage: 'Share link',
                    style: TextStyle(
                      color: theme.buttonBg,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getStyleSheet(Theme theme) {
    return {
      'teamText': TextStyle(
        color: theme.centerChannelColor,
        marginLeft: 12,
        ...typography('Body', 200, 'SemiBold'),
      ),
      'serverText': TextStyle(
        color: changeOpacity(theme.centerChannelColor, 0.72),
        marginLeft: 12,
        ...typography('Body', 75, 'Regular'),
      ),
      'shareLinkText': TextStyle(
        color: theme.buttonBg,
        ...typography('Body', 100, 'SemiBold'),
        paddingLeft: 7,
      ),
    };
  }
}
