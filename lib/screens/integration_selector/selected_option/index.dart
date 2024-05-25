
import 'package:flutter/material.dart';
import 'package:mattermost_flutter/types/theme.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/typography.dart';
import 'package:mattermost_flutter/components/compass_icon.dart';

class SelectedOption extends StatelessWidget {
  final Theme theme;
  final dynamic option; // DialogOption | UserProfile | Channel
  final String dataSource;
  final void Function(dynamic) onRemove;

  SelectedOption({
    required this.theme,
    required this.option,
    required this.dataSource,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final styles = _getStyleFromTheme(theme);

    String text;
    switch (dataSource) {
      case ViewConstants.DATA_SOURCE_USERS:
        text = (option as UserProfile).username;
        break;
      case ViewConstants.DATA_SOURCE_CHANNELS:
        text = (option as Channel).displayName;
        break;
      default:
        text = (option as DialogOption).text;
        break;
    }

    return Container(
      alignment: Alignment.center,
      height: 27,
      decoration: styles.container,
      margin: EdgeInsets.only(bottom: 4, right: 10),
      padding: EdgeInsets.only(left: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              text,
              style: styles.text,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          GestureDetector(
            onTap: () => onRemove(option),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: CompassIcon(
                name: 'close',
                size: 14,
                color: theme.centerChannelColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  _StyleSheet _getStyleFromTheme(Theme theme) {
    return _StyleSheet(
      container: BoxDecoration(
        color: changeOpacity(theme.centerChannelColor, 0.2),
        borderRadius: BorderRadius.circular(3),
      ),
      text: TextStyle(
        color: theme.centerChannelColor,
        ...typography('Body', 100, FontWeight.w400),
      ),
    );
  }
}

class _StyleSheet {
  final BoxDecoration container;
  final TextStyle text;

  _StyleSheet({required this.container, required this.text});
}
