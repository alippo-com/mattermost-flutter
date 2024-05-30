// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Assuming CompassIcon is an SVG icon
import 'package:mattermost_flutter/components/formatted_text.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/utils/tap.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/typography.dart';

class SearchField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = useTheme(context);
    final intl = AppLocalizations.of(context);
    final styles = _getStyleSheet(theme);

    void onPress() {
      preventDoubleTap(() {
        findChannels(
          intl.formatMessage('find_channels.title', 'Find Channels'),
          theme,
        );
      });
    }

    return GestureDetector(
      onTap: onPress,
      child: Container(
        decoration: BoxDecoration(
          color: changeOpacity(theme.sidebarText, 0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(8),
        margin: const EdgeInsets.symmetric(vertical: 20),
        height: 40,
        child: Row(
          children: [
            SvgPicture.asset(
              'assets/icons/magnify.svg', // Assuming the icon is an SVG
              width: 24,
              height: 24,
              color: changeOpacity(theme.sidebarText, 0.72),
            ),
            const SizedBox(width: 5),
            Text(
              intl.formatMessage('channel_list.find_channels', 'Find channels...'),
              style: styles['input'],
            ),
          ],
        ),
      ),
    );
  }

  Map<String, TextStyle> _getStyleSheet(ThemeData theme) {
    return {
      'input': TextStyle(
        color: changeOpacity(theme.sidebarText, 0.72),
        fontSize: 16,
        height: 1.5,
        fontFamily: 'Roboto',
      ),
    };
  }
}
