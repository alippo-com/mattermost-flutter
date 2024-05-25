// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mattermost_flutter/types/theme.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:provider/provider.dart';

class SettingContainer extends StatelessWidget {
  final Widget child;
  final String? testID;

  const SettingContainer({
    Key? key,
    required this.child,
    this.testID,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<Theme>(context);
    final styles = _getStyleSheet(theme);

    return SafeArea(
      left: true,
      right: true,
      child: Container(
        color: theme.centerChannelBg,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(top: 8.0),
          physics: const NeverScrollableScrollPhysics(),
          child: child,
        ),
      ),
    );
  }

  Map<String, dynamic> _getStyleSheet(Theme theme) {
    return {
      'container': BoxDecoration(
        color: theme.centerChannelBg,
      ),
      'contentContainerStyle': EdgeInsets.only(top: 8.0),
    };
  }
}
