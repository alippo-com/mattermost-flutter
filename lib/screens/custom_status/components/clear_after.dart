
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mattermost_flutter/components/compass_icon.dart';
import 'package:mattermost_flutter/components/custom_status/custom_status_expiry.dart';
import 'package:mattermost_flutter/components/formatted_text.dart';
import 'package:mattermost_flutter/utils/theme.dart';

class ClearAfter extends StatelessWidget {
  final String duration;
  final Function onOpenClearAfterModal;
  final ThemeData theme;
  final DateTime expiresAt;

  ClearAfter({
    required this.duration,
    required this.onOpenClearAfterModal,
    required this.theme,
    required this.expiresAt,
  });

  @override
  Widget build(BuildContext context) {
    final style = getStyleSheet(theme);
    final intl = DateFormat();

    Widget renderClearAfterTime() {
      if (duration == 'date_and_time') {
        return Container(
          alignment: Alignment.centerRight,
          child: CustomStatusExpiry(
            textStyles: style['customStatusExpiry'],
            theme: theme,
            time: expiresAt,
            testID: 'custom_status.clear_after.custom_status_duration.$duration.custom_status_expiry',
          ),
        );
      }

      return FormattedText(
        id: CST[duration]['id'],
        defaultMessage: CST[duration]['defaultMessage'],
        style: style['expiryTime'],
        testID: 'custom_status.clear_after.custom_status_duration.$duration.custom_status_expiry',
      );
    }

    return GestureDetector(
      onTap: onOpenClearAfterModal,
      child: Container(
        height: 48,
        color: theme.colorScheme.surface,
        child: Row(
          children: [
            Text(
              intl.formatMessage('mobile.custom_status.clear_after', defaultMessage: 'Clear After'),
              style: style['expiryTimeLabel'],
            ),
            Expanded(child: renderClearAfterTime()),
            CompassIcon(
              name: Icons.chevron_right,
              size: 24,
              color: style['rightIcon'].color,
            ),
          ],
        ),
      ),
    );
  }

  Map<String, TextStyle> getStyleSheet(ThemeData theme) {
    return {
      'rightIcon': TextStyle(
        color: changeOpacity(theme.textTheme.bodyLarge.color, 0.5),
      ),
      'expiryTimeLabel': TextStyle(
        fontSize: 17,
        paddingLeft: 16,
        textAlignVertical: TextAlignVertical.center,
        color: theme.textTheme.bodyLarge.color,
      ),
      'inputContainer': TextStyle(
        height: 48,
        backgroundColor: theme.colorScheme.surface,
      ),
      'expiryTime': TextStyle(
        color: changeOpacity(theme.textTheme.bodyLarge.color, 0.5),
      ),
      'customStatusExpiry': TextStyle(
        color: changeOpacity(theme.textTheme.bodyLarge.color, 0.5),
      ),
    };
  }

  Color changeOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }
}
