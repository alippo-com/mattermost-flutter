// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';

Map<String, Color> getStatusColors(ThemeData theme) {
  return {
    'good': const Color(0xFF00c100),
    'warning': const Color(0xFFdede01),
    'danger': theme.errorColor,
    'default': theme.primaryColor,
    'primary': theme.buttonColor,
    'success': theme.accentColor,
  };
}
