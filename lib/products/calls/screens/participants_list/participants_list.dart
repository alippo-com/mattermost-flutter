import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:bottom_sheet/bottom_sheet.dart';

import 'package:mattermost_flutter/hooks.dart';
import 'package:mattermost_flutter/products/calls/screens/participants_list/participant.dart';
import 'package:mattermost_flutter/products/calls/screens/participants_list/pill.dart';
import 'package:mattermost_flutter/components/formatted_text.dart';
import 'package:mattermost_flutter/constants.dart';
import 'package:mattermost_flutter/theme.dart';
import 'package:mattermost_flutter/device.dart';
import 'package:mattermost_flutter/helpers.dart';


const double rowHeight = 48;
const double headerHeight = 62;
const int minRows = 5;

class ParticipantsList extends HookWidget {
  final String closeButtonId;
  final Map<String, CallSession> sessionsDict;
  final String teammateNameDisplay;

  ParticipantsList({
    required this.closeButtonId,
    required this.sessionsDict,
    required this.teammateNameDisplay,
  });

  @override
  Widget build(BuildContext context) {
    final intl = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final onPress = useHostMenus(context);
    final insets = MediaQuery.of(context).viewInsets;
    final height = MediaQuery.of(context).size.height;
    final isTablet = useIsTablet(context);
    final styles = getStyleSheet(theme);

    final sessions = useMemoized(() => sortSessions(intl.locale, teammateNameDisplay, sessionsDict));
    final snapPoint1 = bottomSheetSnapPoint(Math.min(sessions.length, minRows), rowHeight, insets.bottom) + headerHeight;
    final snapPoint2 = height * 0.8;
    final snapPoints = [1.0, Math.min(snapPoint1, snapPoint2)];
    if (sessions.length > minRows && snapPoint1 < snapPoint2) {
      snapPoints.add(snapPoint2);
    }

    Widget renderItem(CallSession item) {
      return Participant(
        key: ValueKey(item.sessionId),
        sess: item,
        teammateNameDisplay: teammateNameDisplay,
        onPress: onPress(item),
      );
    }

    Widget renderContent() {
      return Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                FormattedText(
                  id: 'mobile.calls_participants',
                  defaultMessage: 'Participants',
                  style: styles.headerText,
                ),
                Pill(text: sessions.length.toString()),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: sessions.length,
              itemBuilder: (context, index) => renderItem(sessions[index]),
            ),
          ),
          Container(height: insets.bottom),
        ],
      );
    }

    return BottomSheet(
      builder: (context) => renderContent(),
      closeButtonId: closeButtonId,
      snapPoints: snapPoints,
    );
  }

  TextStyle get getHeaderTextStyle {
    return TextStyle(
      color: Theme.of(context).colorScheme.onPrimaryContainer,
      fontWeight: FontWeight.w600,
      fontSize: 24,
    );
  }

  Map<String, dynamic> getStyleSheet(ThemeData theme) {
    return {
      'header': {
        'paddingBottom': 12,
        'flexDirection': 'row',
        'gap': 8,
        'alignItems': 'center',
      },
      'headerText': getHeaderTextStyle,
    };
  }
}
