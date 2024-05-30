import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:mattermost_flutter/components/compass_icon.dart';
import 'package:mattermost_flutter/components/touchable_with_feedback.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/utils/tap.dart';
import 'package:mattermost_flutter/utils/theme.dart';

class AddTeam extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final theme = useTheme(context);
    final intl = useIntl(context);

    final onPress = useCallback(() {
      preventDoubleTap(() {
        final title = intl.formatMessage('mobile.add_team.join_team', defaultMessage: 'Join Another Team');
        final closeButton = CompassIcon.getImageSourceSync('close', 24, theme.sidebarHeaderTextColor);
        final closeButtonId = 'close-join-team';
        final options = {
          'topBar': {
            'leftButtons': [
              {
                'id': closeButtonId,
                'icon': closeButton,
                'testID': 'close.join_team.button',
              }
            ]
          }
        };
        showModal(Screens.JOIN_TEAM, title, {'closeButtonId': closeButtonId}, options);
      });
    });

    final styles = getStyleSheet(theme);

    return Container(
      decoration: styles.container,
      child: TouchableWithFeedback(
        onPress: onPress,
        type: 'opacity',
        style: styles.touchable,
        testID: 'team_sidebar.add_team.button',
        child: CompassIcon(
          size: 28,
          name: 'plus',
          color: changeOpacity(theme.sidebarText, 0.64),
        ),
      ),
    );
  }

  getStyleSheet(theme) {
    return {
      'container': BoxDecoration(
        color: changeOpacity(theme.sidebarText, 0.08),
        borderRadius: BorderRadius.circular(10),
        height: 48,
        width: 48,
        margin: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        overflow: Overflow.visible,
      ),
      'touchable': BoxDecoration(
        width: double.infinity,
        height: double.infinity,
        alignment: Alignment.center,
      ),
    };
  }
}
