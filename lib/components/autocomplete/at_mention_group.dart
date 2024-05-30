import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart'; // For ActivityIndicator equivalent
import 'package:mattermost_flutter/components/compass_icon.dart';
import 'package:mattermost_flutter/components/touchable_with_feedback.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/typography.dart';
import 'package:flutter_safe_area/flutter_safe_area.dart';

class GroupMentionItem extends StatelessWidget {
  final String name;
  final String displayName;
  final int memberCount;
  final void Function(String) onPress;
  final String? testID;

  const GroupMentionItem({
    Key? key,
    required this.name,
    required this.displayName,
    required this.memberCount,
    required this.onPress,
    this.testID,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final insets = MediaQuery.of(context).padding;
    final theme = useTheme(context);
    final style = getStyleFromTheme(theme);

    final touchableStyle = [
      style['row'],
      EdgeInsets.only(left: insets.left, right: insets.right),
    ];

    final groupMentionItemTestId = "${testID ?? ''}.$name";

    return TouchableWithFeedback(
      onPress: () => onPress(name),
      style: touchableStyle,
      type: 'opacity',
      testID: groupMentionItemTestId,
      child: Row(
        children: [
          Container(
            margin: EdgeInsets.only(right: 10, left: 2),
            width: 24,
            alignment: Alignment.center,
            child: CompassIcon(
              name: 'account-multiple-outline',
              style: style['rowIcon'],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Text(
                  "$displayName ",
                  style: style['rowDisplayName'],
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  "@$name",
                  style: style['rowName'],
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Text(
            "${memberCount >= 100 ? '99+' : memberCount}",
            style: style['rowTag'],
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Map<String, TextStyle> getStyleFromTheme(ThemeData theme) {
    return {
      'row': TextStyle(
        height: 40,
        paddingVertical: 8,
        paddingTop: 4,
        flexDirection: 'row',
        alignItems: 'center',
      ),
      'rowPicture': TextStyle(
        marginRight: 10,
        marginLeft: 2,
        width: 24,
        alignItems: 'center',
        justifyContent: 'center',
      ),
      'rowIcon': TextStyle(
        color: changeOpacity(theme.centerChannelColor, 0.64),
        fontSize: 22,
      ),
      'rowInfo': TextStyle(
        flexDirection: 'row',
        alignItems: 'center',
        overflow: 'hidden',
        maxWidth: '80%',
        paddingLeft: 3,
      ),
      'rowDisplayName': typography(
        'Body',
        200,
      ).copyWith(
        color: theme.centerChannelColor,
        flexShrink: 1,
      ),
      'rowName': typography(
        'Body',
        200,
      ).copyWith(
        color: changeOpacity(theme.centerChannelColor, 0.64),
        flexShrink: 2,
        marginLeft: 2,
      ),
      'rowTag': typography(
        'Heading',
        25,
      ).copyWith(
        backgroundColor: changeOpacity(theme.centerChannelColor, 0.08),
        color: changeOpacity(theme.centerChannelColor, 0.64),
        marginLeft: 'auto',
        width: 20,
        borderRadius: 4,
        overflow: 'hidden',
        marginTop: 2,
        paddingHorizontal: 4,
        textAlign: TextAlign.center,
      ),
    };
  }
}
