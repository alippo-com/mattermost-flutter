
import 'package:flutter/material.dart';
import 'package:mattermost_flutter/components/compass_icon.dart';
import 'package:mattermost_flutter/components/formatted_text.dart';
import 'package:mattermost_flutter/components/touchable_with_feedback.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/change_opacity.dart';

class SpecialMentionItem extends StatelessWidget {
  final String completeHandle;
  final String defaultMessage;
  final String id;
  final Function(String) onPress;
  final String? testID;

  SpecialMentionItem({
    required this.completeHandle,
    required this.defaultMessage,
    required this.id,
    required this.onPress,
    this.testID,
  });

  @override
  Widget build(BuildContext context) {
    final theme = useTheme(context);
    final style = getStyleFromTheme(theme);
    final completeMention = () => onPress(completeHandle);

    final specialMentionItemTestId = '$testID.$id';

    return TouchableWithFeedback(
      onPress: completeMention,
      underlayColor: changeOpacity(theme.buttonBg, 0.08),
      testID: specialMentionItemTestId,
      type: 'native',
      child: Container(
        height: 40,
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              margin: EdgeInsets.only(right: 8),
              width: 20,
              alignment: Alignment.center,
              child: CompassIcon(
                name: 'account-multiple-outline',
                style: TextStyle(
                  color: changeOpacity(theme.centerChannelColor, 0.7),
                  fontSize: 18,
                ),
              ),
            ),
            Expanded(
              child: Text(
                '@$completeHandle - ',
                style: TextStyle(
                  fontSize: 15,
                  color: theme.centerChannelColor,
                ),
              ),
            ),
            Expanded(
              child: FormattedText(
                id: id,
                defaultMessage: defaultMessage,
                style: TextStyle(
                  color: theme.centerChannelColor,
                  opacity: 0.6,
                ),
                testID: '$specialMentionItemTestId.display_name',
              ),
            )
          ],
        ),
      ),
    );
  }

  getStyleFromTheme(ThemeData theme) {
    return {
      'row': TextStyle(
        height: 40,
        paddingVertical: 8,
        flexDirection: 'row',
        alignItems: 'center',
      ),
      'rowPicture': TextStyle(
        marginRight: 8,
        width: 20,
        alignItems: 'center',
        justifyContent: 'center',
      ),
      'rowIcon': TextStyle(
        color: changeOpacity(theme.centerChannelColor, 0.7),
        fontSize: 18,
      ),
      'rowUsername': TextStyle(
        fontSize: 15,
        color: theme.centerChannelColor,
      ),
      'rowFullname': TextStyle(
        color: theme.centerChannelColor,
        flex: 1,
        opacity: 0.6,
      ),
      'textWrapper': TextStyle(
        flex: 1,
        flexWrap: 'wrap',
        paddingRight: 8,
      ),
    };
  }
}
