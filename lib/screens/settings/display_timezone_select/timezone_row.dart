import 'package:flutter/material.dart';
import 'package:mattermost_flutter/types/database.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/queries/servers/system.dart';
import 'package:mattermost_flutter/components/compass_icon.dart';
import 'package:mattermost_flutter/components/settings_separator.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/utils/typography.dart';

const double ITEM_HEIGHT = 48.0;

class TimezoneRow extends StatelessWidget {
  final bool isSelected;
  final Function(String) onPressTimezone;
  final String timezone;

  TimezoneRow({
    required this.isSelected,
    required this.onPressTimezone,
    required this.timezone,
  });

  @override
  Widget build(BuildContext context) {
    final theme = useTheme(context);
    final styles = _getStyleSheet(theme);

    final timezoneRowTestId = isSelected
        ? 'select_timezone.timezone_row.$timezone.selected'
        : 'select_timezone.timezone_row.$timezone';

    return GestureDetector(
      key: Key(timezoneRowTestId),
      onTap: () => onPressTimezone(timezone),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 18.0),
        height: ITEM_HEIGHT,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    timezone,
                    style: styles['itemText'],
                  ),
                ),
                if (isSelected)
                  CompassIcon(
                    color: theme.linkColor,
                    name: 'check',
                    size: 24,
                  ),
              ],
            ),
            SettingsSeparator(
              lineStyles: styles['lineStyles'],
            ),
          ],
        ),
      ),
    );
  }

  Map<String, TextStyle> _getStyleSheet(ThemeData theme) {
    return {
      'itemText': typography('Body', 200).copyWith(color: theme.centerChannelColor),
      'lineStyles': TextStyle(),
    };
  }
}
