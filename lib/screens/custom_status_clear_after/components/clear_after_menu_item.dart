import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mattermost_flutter/constants/custom_status.dart';
import 'package:mattermost_flutter/utils/helpers.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/components/compass_icon.dart';
import 'package:mattermost_flutter/components/custom_status/custom_status_expiry.dart';
import 'package:mattermost_flutter/components/custom_status/custom_status_text.dart';
import 'package:mattermost_flutter/screens/custom_status_clear_after/components/date_time_selector.dart';
import 'package:mattermost_flutter/types/database/models/servers/user.dart';

class ClearAfterMenuItem extends StatelessWidget {
  final UserModel? currentUser;
  final CustomStatusDuration duration;
  final String expiryTime;
  final Function(CustomStatusDuration, String) handleItemClick;
  final bool isSelected;
  final bool separator;
  final bool showDateTimePicker;
  final bool showExpiryTime;

  ClearAfterMenuItem({
    this.currentUser,
    required this.duration,
    this.expiryTime = '',
    required this.handleItemClick,
    required this.isSelected,
    required this.separator,
    this.showDateTimePicker = false,
    this.showExpiryTime = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = useTheme(context);
    final intl = Intl.of(context);
    final style = _getStyleSheet(theme);

    final expiryMenuItems = {
      CustomStatusDurationEnum.DONT_CLEAR: intl.formatMessage(CST[CustomStatusDurationEnum.DONT_CLEAR]),
      CustomStatusDurationEnum.THIRTY_MINUTES: intl.formatMessage(CST[CustomStatusDurationEnum.THIRTY_MINUTES]),
      CustomStatusDurationEnum.ONE_HOUR: intl.formatMessage(CST[CustomStatusDurationEnum.ONE_HOUR]),
      CustomStatusDurationEnum.FOUR_HOURS: intl.formatMessage(CST[CustomStatusDurationEnum.FOUR_HOURS]),
      CustomStatusDurationEnum.TODAY: intl.formatMessage(CST[CustomStatusDurationEnum.TODAY]),
      CustomStatusDurationEnum.THIS_WEEK: intl.formatMessage(CST[CustomStatusDurationEnum.THIS_WEEK]),
      CustomStatusDurationEnum.DATE_AND_TIME: intl.formatMessage(MessageLookupByLibrary.simpleMessage('Custom')),
    };

    void handleClick() {
      handleItemClick(duration, expiryTime);
    }

    void handleCustomExpiresAtChange(DateTime expiresAt) {
      handleItemClick(duration, expiresAt.toIso8601String());
    }

    final clearAfterMenuItemTestId = 'custom_status_clear_after.menu_item.$duration';

    return Column(
      children: [
        GestureDetector(
          onTap: handleClick,
          child: Container(
            padding: EdgeInsets.all(10),
            color: theme.centerChannelBg,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(left: 5, bottom: 2),
                    child: CustomStatusText(
                      text: expiryMenuItems[duration]!,
                      theme: theme,
                      textStyle: TextStyle(color: theme.centerChannelColor),
                      testID: '$clearAfterMenuItemTestId.custom_status_text',
                    ),
                  ),
                ),
                if (isSelected)
                  Positioned(
                    right: 14,
                    child: CompassIcon(
                      name: 'check',
                      size: 24,
                      color: theme.buttonBg,
                    ),
                  ),
                if (showExpiryTime && expiryTime.isNotEmpty)
                  Positioned(
                    right: 14,
                    child: CustomStatusExpiry(
                      theme: theme,
                      time: DateFormatToDate(expiryTime),
                      textStyles: TextStyle(color: theme.linkColor),
                      showTimeCompulsory: true,
                      showToday: true,
                      testID: '$clearAfterMenuItemTestId.custom_status_expiry',
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (separator)
          Divider(
            color: changeOpacity(theme.centerChannelColor, 0.2),
            height: 1,
            indent: 16,
            endIndent: 16,
          ),
        if (showDateTimePicker)
          DateTimePicker(
            handleChange: handleCustomExpiresAtChange,
            theme: theme,
            timezone: getTimezone(currentUser?.timezone),
          ),
      ],
    );
  }

  TextStyle _getStyleSheet(ThemeData theme) {
    return TextStyle(
      backgroundColor: theme.centerChannelBg,
      flexDirection: 'row',
      padding: EdgeInsets.all(10),
      textColor: theme.centerChannelColor,
      linkColor: theme.linkColor,
      buttonBg: theme.buttonBg,
      borderRadius: BorderRadius.circular(1000),
    );
  }
}
