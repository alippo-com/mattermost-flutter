
// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:mattermost_flutter/components/profile_picture.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/database/observe_current_user.dart';
import 'package:mattermost_flutter/types/database.dart';
import 'package:mattermost_flutter/types/user_model.dart';

class Account extends HookConsumerWidget {
  final bool isFocused;
  final ThemeData theme;

  Account({
    required this.isFocused,
    required this.theme,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(observeCurrentUserProvider);

    final style = _getStyleSheet(theme);

    return Container(
      decoration: isFocused ? style['selected'] : null,
      child: ProfilePicture(
        author: currentUser,
        showStatus: true,
        size: 28,
      ),
    );
  }

  Map<String, BoxDecoration> _getStyleSheet(ThemeData theme) {
    return {
      'selected': BoxDecoration(
        border: Border.all(width: 2, color: theme.buttonColor),
        borderRadius: BorderRadius.circular(20),
      ),
    };
  }
}
