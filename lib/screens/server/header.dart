
// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:mattermost_flutter/utils/device.dart';
import 'package:mattermost_flutter/components/formatted_text.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/types/typography.dart';

class ServerHeaderProps {
  final bool additionalServer;
  final Theme theme;

  ServerHeaderProps({required this.additionalServer, required this.theme});
}

TextStyle welcomeStyle(Theme theme) {
  return TextStyle(
    margin: EdgeInsets.only(top: 12),
    color: changeOpacity(theme.centerChannelColor, 0.64),
    fontFamily: typography('Heading', 400, 'SemiBold'),
  );
}

TextStyle connectStyle(Theme theme, bool isTablet) {
  return TextStyle(
    width: isTablet ? null : 300,
    letterSpacing: -1,
    color: theme.centerChannelColor,
    margin: EdgeInsets.symmetric(vertical: 12),
    fontFamily: typography('Heading', 1000, 'SemiBold'),
  );
}

TextStyle descriptionStyle(Theme theme) {
  return TextStyle(
    color: changeOpacity(theme.centerChannelColor, 0.64),
    fontFamily: typography('Body', 200, 'Regular'),
  );
}

BoxDecoration textContainerStyle() {
  return BoxDecoration(
    margin: EdgeInsets.only(bottom: 32),
    maxWidth: 600,
    width: '100%',
    padding: EdgeInsets.symmetric(horizontal: 20),
  );
}

class ServerHeader extends StatelessWidget {
  final ServerHeaderProps props;

  ServerHeader({required this.props});

  @override
  Widget build(BuildContext context) {
    final isTablet = useIsTablet();
    final styles = getStyleSheet(props.theme);

    Widget title;
    if (props.additionalServer) {
      title = FormattedText(
        defaultMessage: 'Add a server',
        id: 'servers.create_button',
        style: connectStyle(props.theme, isTablet),
        testID: 'server_header.title.add_server',
      );
    } else {
      title = FormattedText(
        defaultMessage: 'Let’s Connect to a Server',
        id: 'mobile.components.select_server_view.msg_connect',
        style: connectStyle(props.theme, isTablet),
        testID: 'server_header.title.connect_to_server',
      );
    }

    return Container(
      decoration: textContainerStyle(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!props.additionalServer)
            FormattedText(
              defaultMessage: 'Welcome',
              id: 'mobile.components.select_server_view.msg_welcome',
              style: welcomeStyle(props.theme),
              testID: 'server_header.welcome',
            ),
          title,
          FormattedText(
            defaultMessage: "A server is your team's communication hub accessed using a unique URL",
            id: 'mobile.components.select_server_view.msg_description',
            style: descriptionStyle(props.theme),
            testID: 'server_header.description',
          ),
        ],
      ),
    );
  }
}
