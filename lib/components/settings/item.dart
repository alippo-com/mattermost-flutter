import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io' show Platform;

import 'package:mattermost_flutter/components/option_item.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/typography.dart';
import 'package:mattermost_flutter/screens/settings/config.dart';
import 'package:mattermost_flutter/components/settings/separator.dart';

typedef SettingsConfig = String;

class SettingOptionProps {
  final SettingsConfig optionName;
  final VoidCallback onPress;
  final bool separator;
  final OptionItemProps? optionItemProps;

  SettingOptionProps({
    required this.optionName,
    required this.onPress,
    this.separator = true,
    this.optionItemProps,
  });
}

TextStyle getMenuLabelStyle(ThemeData theme) {
  return TextStyle(
    color: theme.centerChannelColor,
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );
}

TextStyle getChevronStyle(ThemeData theme) {
  return TextStyle(
    marginRight: 14,
    color: changeOpacity(theme.centerChannelColor, 0.32),
  );
}

class SettingItem extends StatelessWidget {
  final SettingOptionProps props;

  SettingItem({
    required this.props,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeData>(context);
    final styles = getStyleSheet(theme);
    final config = Options[props.optionName];

    final label = props.optionItemProps?.label ?? config.i18nId;

    return Column(
      children: [
        OptionItem(
          onTap: props.onPress,
          arrowStyle: getChevronStyle(theme),
          containerStyle: EdgeInsets.only(left: 16),
          icon: config.icon,
          info: props.optionItemProps?.info,
          label: label,
          optionLabelTextStyle: getMenuLabelStyle(theme),
          type: Platform.isIOS ? 'arrow' : 'default',
        ),
        if (props.separator) SettingSeparator(),
      ],
    );
  }
}
