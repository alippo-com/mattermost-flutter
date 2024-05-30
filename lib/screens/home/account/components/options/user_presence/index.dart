
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:mattermost_flutter/actions/user_actions.dart';
import 'package:mattermost_flutter/components/formatted_text.dart';
import 'package:mattermost_flutter/components/slide_up_panel_item.dart';
import 'package:mattermost_flutter/components/status_label.dart';
import 'package:mattermost_flutter/components/user_status_indicator.dart';
import 'package:mattermost_flutter/constants/general.dart';
import 'package:mattermost_flutter/context/server_context.dart';
import 'package:mattermost_flutter/context/theme_context.dart';
import 'package:mattermost_flutter/hooks/device_hooks.dart';
import 'package:mattermost_flutter/screens/bottom_sheet_content.dart';
import 'package:mattermost_flutter/utils/tap.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/typography.dart';

import 'package:mattermost_flutter/types/user_model.dart';

class UserStatus extends StatelessWidget {
  final UserModel currentUser;

  UserStatus({required this.currentUser});

  @override
  Widget build(BuildContext context) {
    final intl = Intl.message;
    final bottom = MediaQuery.of(context).padding.bottom;
    final serverUrl = context.read<ServerContext>().serverUrl;
    final theme = context.read<ThemeContext>().theme;
    final isTablet = useIsTablet(context);

    final styles = _getStyleSheet(theme);

    void handleSetStatus() {
      preventDoubleTap(() {
        Widget renderContent() {
          return Column(
            children: [
              if (!isTablet)
                Container(
                  margin: EdgeInsets.only(bottom: 12),
                  child: FormattedText(
                    id: 'user_status.title',
                    defaultMessage: 'Status',
                    style: styles.listHeaderText,
                  ),
                ),
              SlideUpPanelItem(
                leftIcon: Icons.check_circle,
                leftIconStyles: TextStyle(color: theme.onlineIndicator),
                onPress: () => setUserStatus(General.ONLINE),
                testID: 'user_status.online.option',
                text: intl('user_status.online', defaultMessage: 'Online'),
                textStyles: styles.label,
              ),
              SlideUpPanelItem(
                leftIcon: Icons.access_time,
                leftIconStyles: TextStyle(color: theme.awayIndicator),
                onPress: () => setUserStatus(General.AWAY),
                testID: 'user_status.away.option',
                text: intl('user_status.away', defaultMessage: 'Away'),
                textStyles: styles.label,
              ),
              SlideUpPanelItem(
                leftIcon: Icons.remove_circle,
                leftIconStyles: TextStyle(color: theme.dndIndicator),
                onPress: () => setUserStatus(General.DND),
                testID: 'user_status.dnd.option',
                text: intl('user_status.dnd', defaultMessage: 'Do Not Disturb'),
                textStyles: styles.label,
              ),
              SlideUpPanelItem(
                leftIcon: Icons.radio_button_unchecked,
                leftIconStyles: TextStyle(color: changeOpacity(Color(0xB8B8B8), 0.64)),
                onPress: () => setUserStatus(General.OFFLINE),
                testID: 'user_status.offline.option',
                text: intl('user_status.offline', defaultMessage: 'Offline'),
                textStyles: styles.label,
              ),
            ],
          );
        }

        final snapPoint = bottomSheetSnapPoint(4, ITEM_HEIGHT, bottom);
        bottomSheet(
          context: context,
          closeButtonId: 'close-set-user-status',
          renderContent: renderContent,
          snapPoints: [1, snapPoint + TITLE_HEIGHT],
          title: intl('user_status.title', defaultMessage: 'Status'),
          theme: theme,
        );
      });
    }

    void updateStatus(String status) {
      final userStatus = {
        'user_id': currentUser.id,
        'status': status,
        'manual': true,
        'last_activity_at': DateTime.now().millisecondsSinceEpoch,
      };

      setStatus(serverUrl, userStatus);
    }

    void setUserStatus(String status) {
      if (currentUser.status == General.OUT_OF_OFFICE) {
        dismissModal(context);
        confirmOutOfOfficeDisabled(context, intl, status, updateStatus);
        return;
      }

      updateStatus(status);
      dismissBottomSheet(context);
      return;
    }

    return GestureDetector(
      onTap: handleSetStatus,
      child: Container(
        margin: EdgeInsets.only(top: 18),
        child: Row(
          children: [
            UserStatusIndicator(
              size: 24,
              status: currentUser.status,
            ),
            StatusLabel(
              labelStyle: styles.label.merge(TextStyle(marginLeft: 16)),
              status: currentUser.status,
            ),
          ],
        ),
      ),
    );
  }

  _getStyleSheet(ThemeData theme) {
    return {
      'label': TextStyle(
        color: theme.centerChannelColor,
        textAlignVertical: TextAlignVertical.center,
      ),
      'body': Row(
        children: [],
        marginTop: 18,
      ),
      'spacer': EdgeInsets.only(left: 16),
      'listHeader': Container(
        marginBottom: 12,
      ),
      'listHeaderText': TextStyle(
        color: theme.centerChannelColor,
        fontWeight: FontWeight.w600,
      ),
    };
  }
}
