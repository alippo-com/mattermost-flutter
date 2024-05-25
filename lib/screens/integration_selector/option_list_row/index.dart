import 'package:flutter/material.dart';
import 'package:mattermost_flutter/types.dart'; // Adjust the path as necessary
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/typography.dart';
import 'package:mattermost_flutter/screens/integration_selector/custom_list_row.dart';

class OptionListRow extends StatelessWidget {
  final String id;
  final Theme theme;
  final Map<String, String> item;
  final Function(Map<String, String>) onPress;
  final bool enabled;
  final bool selectable;
  final bool selected;

  OptionListRow({
    required this.id,
    required this.theme,
    required this.item,
    required this.onPress,
    required this.enabled,
    required this.selectable,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    final text = item['text'];
    final style = getStyleFromTheme(theme);

    void onPressRow() {
      onPress(item);
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15),
      height: 65,
      decoration: BoxDecoration(
        color: theme.centerChannelBg,
      ),
      child: Row(
        children: [
          CustomListRow(
            id: id,
            onPress: onPressRow,
            enabled: enabled,
            selectable: selectable,
            selected: selected,
            child: Container(
              margin: EdgeInsets.only(left: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text ?? '',
                    style: TextStyle(
                      color: theme.centerChannelColor,
                      fontSize: 14, // Adjust based on typography
                      fontWeight: FontWeight.normal, // Adjust based on typography
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

  Map<String, dynamic> getStyleFromTheme(Theme theme) {
    return {
      'container': {
        'flexDirection': 'row',
        'height': 65,
        'paddingHorizontal': 15,
        'alignItems': 'center',
        'backgroundColor': theme.centerChannelBg,
      },
      'textContainer': {
        'marginLeft': 10,
        'justifyContent': 'center',
        'flexDirection': 'column',
        'flex': 1,
      },
      'optionText': {
        'color': theme.centerChannelColor,
        ...typography('Body', 200, 'Regular'),
      },
    };
  }
}
