// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:mattermost_flutter/components/option_item.dart';

class BaseOption extends StatelessWidget {
  final String defaultMessage;
  final String i18nId;
  final String iconName;
  final bool isDestructive;
  final VoidCallback onPress;
  final String testID;

  BaseOption({
    required this.defaultMessage,
    required this.i18nId,
    required this.iconName,
    this.isDestructive = false,
    required this.onPress,
    required this.testID,
  });

  @override
  Widget build(BuildContext context) {
    return OptionItem(
      action: onPress,
      destructive: isDestructive,
      icon: iconName,
      label: i18nId, // This should be replaced with the localized message
      testID: testID,
      type: 'default',
    );
  }
}
