// Converted from ./mattermost-mobile/app/screens/select_team/no_teams.tsx

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mattermost_flutter/components/illustrations/no_team.dart';
import 'package:mattermost_flutter/utils/button_styles.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/typography.dart';

class NoTeams extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final styles = _getStyleSheet(theme);
    final intl = AppLocalizations.of(context)!;

    return Container(
      alignment: Alignment.center,
      margin: EdgeInsets.symmetric(horizontal: 24),
      constraints: BoxConstraints(maxWidth: 600),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 120,
            width: 120,
            decoration: BoxDecoration(
              color: changeOpacity(theme.sidebarText, 0.08),
              borderRadius: BorderRadius.circular(60),
            ),
            child: Center(
              child: Empty(theme: theme),
            ),
          ),
          Text(
            intl.select_team_no_team_title,
            style: styles['title'],
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 12),
          Text(
            intl.select_team_no_team_description,
            style: styles['description'],
            textAlign: TextAlign.center,
          ),
          // TODO: Uncomment when the feature is ready
          // if (canCreateTeams)
          //   GestureDetector(
          //     onTap: onButtonPress,
          //     child: Container(
          //       decoration: styles['buttonStyle'],
          //       child: Row(
          //         mainAxisAlignment: MainAxisAlignment.center,
          //         children: [
          //           Icon(
          //             Icons.add,
          //             color: theme.sidebarText,
          //             size: 24,
          //           ),
          //           SizedBox(width: 8),
          //           Text(
          //             intl.mobile_add_team_create_team,
          //             style: styles['buttonText'],
          //           ),
          //         ],
          //       ),
          //     ),
          //   ),
        ],
      ),
    );
  }

  Map<String, TextStyle> _getStyleSheet(ThemeData theme) {
    return {
      'title': TextStyle(
        color: theme.sidebarHeaderTextColor,
        marginTop: 24,
        ...typography('Heading', 800),
      ),
      'description': TextStyle(
        color: changeOpacity(theme.sidebarText, 0.72),
        marginTop: 12,
        ...typography('Body', 200, 'Regular'),
      ),
      'buttonText': TextStyle(
        ...buttonTextStyle(theme, 'lg', 'primary', 'default'),
        marginLeft: 8,
      ),
    };
  }
}
