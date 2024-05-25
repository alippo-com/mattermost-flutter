
// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mattermost_flutter/components/settings/option.dart';
import 'package:mattermost_flutter/components/settings/separator.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/intl.dart';

class CustomTheme extends StatelessWidget {
  final Function(String) setTheme;
  final String? displayTheme;

  CustomTheme({required this.setTheme, this.displayTheme});

  @override
  Widget build(BuildContext context) {
    final intl = Intl.of(context);
    final theme = useTheme(context);

    return Column(
      children: <Widget>[
        SettingSeparator(isGroupSeparator: true),
        SettingOption(
          action: setTheme,
          type: 'select',
          value: 'custom',
          label: intl.formatMessage('settings_display.custom_theme', defaultMessage: 'Custom Theme'),
          selected: theme.type?.toLowerCase() == displayTheme?.toLowerCase(),
          radioItemProps: {'checkedBody': true},
          testID: 'theme_display_settings.custom.option',
        ),
      ],
    );
  }
}
