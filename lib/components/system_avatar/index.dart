// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:mattermost_flutter/components/compass_icon.dart';
import 'package:mattermost_flutter/constants/view.dart';

class SystemAvatar extends StatelessWidget {
  final ThemeData theme;

  const SystemAvatar({
    Key? key,
    required this.theme,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CompassIcon(
      name: 'mattermost',
      color: theme.centerChannelColor,
      size: ViewConstants.PROFILE_PICTURE_SIZE,
    );
  }
}
