// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:mattermost_flutter/components/compass_icon.dart';
import 'package:mattermost_flutter/components/touchable_with_feedback.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/typography.dart';

class AddTeamItem extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = useTheme();
    final intl = useIntl();
    final styles = getStyleSheet(theme);

    final onPress = useCallback(() async {
      // TODO: https://mattermost.atlassian.net/browse/MM-43622
      goToScreen(Screens.CREATE_TEAM, 'Create team');
    }, []);

    return Container(
      height: 64,
      marginBottom: 2,
      child: TouchableWithFeedback(
        onPress: onPress,
        type: 'opacity',
        style: styles.touchable,
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              child: Center(
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: changeOpacity(theme.sidebarText, 0.16),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: CompassIcon(
                    name: 'plus',
                    style: styles.icon,
                  ),
                ),
              ),
            ),
            SizedBox(width: 16),
            Text(
              intl.formatMessage({
                'id': 'mobile.add_team.create_team',
                'defaultMessage': 'Create a new team'
              }),
              style: styles.text,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> getStyleSheet(Theme theme) {
    return {
      'container': {
        'height': 64,
        'marginBottom': 2,
      },
      'touchable': {
        'display': 'flex',
        'flexDirection': 'row',
        'borderRadius': 4,
        'alignItems': 'center',
        'height': '100%',
        'width': '100%',
      },
      'text': {
        'color': theme.sidebarText,
        'marginLeft': 16,
        ...typography('Body', 200),
      },
      'icon_container_container': {
        'width': 40,
        'height': 40,
      },
      'icon_container': {
        'width': '100%',
        'height': '100%',
        'alignItems': 'center',
        'justifyContent': 'center',
        'backgroundColor': changeOpacity(theme.sidebarText, 0.16),
        'borderRadius': 10,
      },
      'icon': {
        'color': theme.sidebarText,
        'fontSize': 24,
      },
    };
  }
}
