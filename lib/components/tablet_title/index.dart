import 'package:flutter/material.dart';
import 'package:mattermost_flutter/components/touchable_with_feedback.dart';
import 'package:mattermost_flutter/types/theme.dart';
import 'package:mattermost_flutter/utils/theme.dart';

class TabletTitle extends StatelessWidget {
  final String? action;
  final bool enabled;
  final VoidCallback? onPress;
  final String title;
  final String testID;

  TabletTitle({
    this.action,
    this.enabled = true,
    this.onPress,
    required this.title,
    required this.testID,
  });

  @override
  Widget build(BuildContext context) {
    final theme = useTheme(context);
    final styles = getStyleSheet(theme);
    final textStyle = [styles['action'], if (enabled) styles['enabled']];

    return Container(
      color: styles['container']['backgroundColor'],
      child: Column(
        children: [
          Container(
            height: 34,
            width: double.infinity,
            padding: EdgeInsets.only(bottom: 5),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: styles['container']['borderBottomColor'],
                  width: 1,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Center(
                    child: Text(
                      title,
                      style: styles['title'],
                      key: Key('${testID}.title'),
                    ),
                  ),
                ),
                if (action != null)
                  Positioned(
                    right: 20,
                    bottom: 7,
                    child: TouchableWithFeedback(
                      disabled: !enabled,
                      onPressed: onPress,
                      type: Platform.isAndroid ? 'native' : 'opacity',
                      key: Key('${testID}.${action!.toLowerCase()}.button'),
                      underlayColor: changeOpacity(theme.centerChannelColor, 0.1),
                      child: Text(action!, style: textStyle,),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> getStyleSheet(Theme theme) {
    return {
      'actionContainer': {
        'alignItems': Alignment.centerRight,
        'justifyContent': MainAxisAlignment.center,
        'right': 20.0,
        'bottom': 7.0,
        'position': 'absolute',
      },
      'action': TextStyle(
        color: changeOpacity(theme.centerChannelColor, 0.7),
        fontFamily: 'OpenSans-SemiBold',
        fontSize: 16.0,
        height: 24.0 / 16.0,
      ),
      'container': {
        'backgroundColor': theme.centerChannelBg,
        'borderBottomColor': changeOpacity(theme.centerChannelColor, 0.08),
        'flexDirection': 'row',
        'height': 34.0,
        'width': double.infinity,
        'alignItems': Alignment.center,
        'paddingBottom': 5.0,
      },
      'enabled': TextStyle(
        color: theme.buttonBg,
      ),
      'titleContainer': {
        'alignItems': Alignment.center,
        'flex': 1,
        'justifyContent': MainAxisAlignment.center,
      },
      'title': TextStyle(
        color: theme.centerChannelColor,
        fontFamily: 'OpenSans-SemiBold',
        fontSize: 18.0,
        height: 24.0 / 18.0,
      ),
    };
  }
}
