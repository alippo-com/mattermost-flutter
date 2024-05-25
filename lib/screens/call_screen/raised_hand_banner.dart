import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:mattermost_flutter/calls/utils.dart';
import 'package:mattermost_flutter/components/compass_icon.dart';
import 'package:mattermost_flutter/components/formatted_text.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/typography.dart';
import 'package:mattermost_flutter/types/calls/calls.dart';

class RaisedHandBanner extends StatelessWidget {
  final List<CallSession> raisedHands;
  final String sessionId;
  final String teammateNameDisplay;

  const RaisedHandBanner({
    Key? key,
    required this.raisedHands,
    required this.sessionId,
    required this.teammateNameDisplay,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final intl = Intl.defaultLocale;
    final theme = useTheme(context);
    final callsTheme = makeCallsTheme(theme);
    final style = getStyleSheet(callsTheme);

    if (raisedHands.isEmpty) {
      return Container(
        height: 0,
        width: 0,
      );
    }

    final names = getHandsRaisedNames(raisedHands, sessionId, intl, teammateNameDisplay, intl);

    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(6, 4, 18, 4),
            margin: EdgeInsets.symmetric(horizontal: 5),
            decoration: BoxDecoration(
              color: callsTheme.sidebarText,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                CompassIcon(
                  name: 'hand-right',
                  size: 16,
                  color: callsTheme.awayIndicator,
                ),
                FormattedText(
                  style: TextStyle(
                    color: callsTheme.sidebarTeamBarBg,
                    fontWeight: FontWeight.bold,
                  ),
                  id: 'mobile.calls_raised_hand',
                  defaultMessage: '<bold>{name} {num, plural, =0 {} other {+# more }}</bold> raised a hand',
                  values: {
                    'name': names[0],
                    'num': names.length - 1,
                    'bold': (str) => Text(
                      str,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: callsTheme.sidebarTeamBarBg,
                      ),
                    ),
                  },
                  numberOfLines: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  TextStyle getStyleSheet(CallsTheme theme) {
    return TextStyle(
      color: theme.sidebarText,
      fontSize: 16,
    );
  }
}
