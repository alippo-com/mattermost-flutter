// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:mattermost_flutter/types/theme.dart';
import 'package:mattermost_flutter/utils/theme_utils.dart';

const double MARGIN_VERTICAL = 8.0;
const double BORDER = 1.0;
const double SEPARATOR_HEIGHT = (MARGIN_VERTICAL * 2) + BORDER;

class PlusMenuSeparator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = _getStyleSheet(theme);

    return Container(
      margin: EdgeInsets.symmetric(vertical: MARGIN_VERTICAL),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: changeOpacity(theme.colorScheme.primary, 0.08),
            width: BORDER,
          ),
        ),
      ),
    );
  }

  BoxDecoration _getStyleSheet(ThemeData theme) {
    return BoxDecoration(
      border: Border(
        top: BorderSide(
          color: changeOpacity(theme.colorScheme.primary, 0.08),
          width: BORDER,
        ),
      ),
    );
  }
}
