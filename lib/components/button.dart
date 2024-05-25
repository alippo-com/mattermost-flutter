
// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';

enum ButtonSize { xs, s, m, lg }
enum ButtonEmphasis { primary, secondary, tertiary, link }
enum ButtonType { defaultType, destructive, inverted, disabled }
enum ButtonState { defaultState, hover, active, focus }

class ButtonStyles {
  static final Map<ButtonSize, TextStyle> sizes = {
    ButtonSize.xs: TextStyle(fontSize: 8),
    ButtonSize.s: TextStyle(fontSize: 12),
    ButtonSize.m: TextStyle(fontSize: 16),
    ButtonSize.lg: TextStyle(fontSize: 20),
  };

  static final Map<ButtonEmphasis, Map<ButtonType, Map<ButtonState, BoxDecoration>>> styles = {
    ButtonEmphasis.primary: {
      ButtonType.defaultType: {
        ButtonState.defaultState: BoxDecoration(color: Colors.blue),
        ButtonState.hover: BoxDecoration(color: Colors.blue.shade700),
        ButtonState.active: BoxDecoration(color: Colors.blue.shade800),
        ButtonState.focus: BoxDecoration(color: Colors.blue.shade600),
      },
      ButtonType.destructive: {
        ButtonState.defaultState: BoxDecoration(color: Colors.red),
        ButtonState.hover: BoxDecoration(color: Colors.red.shade700),
        ButtonState.active: BoxDecoration(color: Colors.red.shade800),
        ButtonState.focus: BoxDecoration(color: Colors.red.shade600),
      },
      // Additional mappings can be added here
    },
    // Additional emphasis can be added here
  };
}
