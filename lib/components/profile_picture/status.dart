// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:mattermost_flutter/types/database.dart';
import 'package:mattermost_flutter/components/user_status.dart';
import 'package:mattermost_flutter/utils/theme.dart';

import 'package:mattermost_flutter/types/user_model.dart';

class Status extends StatelessWidget {
  final UserModel? author;
  final double statusSize;
  final TextStyle? statusStyle;
  final Theme theme;

  const Status({
    Key? key,
    this.author,
    required this.statusSize,
    this.statusStyle,
    required this.theme,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final styles = getStyleSheet(theme);
    final containerStyle = [
      styles['statusWrapper'],
      statusStyle,
      {'borderRadius': statusSize / 2},
    ];
    final isBot = author != null && (author!.isBot ?? author!.is_bot);
    if (author?.status != null && !isBot) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(statusSize / 2),
          color: theme.centerChannelBg,
          border: Border.all(color: theme.centerChannelBg, width: 1),
        ),
        child: UserStatus(
          size: statusSize,
          status: author!.status!,
        ),
      );
    }
    return Container();
  }

  Map<String, dynamic> getStyleSheet(Theme theme) {
    return {
      'statusWrapper': {
        'position': 'absolute',
        'bottom': -Platform.select({'ios': 3, 'default': 2}),
        'right': -Platform.select({'ios': 3, 'default': 2}),
        'overflow': 'hidden',
        'alignItems': 'center',
        'justifyContent': 'center',
        'backgroundColor': theme.centerChannelBg,
        'borderWidth': 1,
        'borderColor': theme.centerChannelBg,
      },
    };
  }
}
