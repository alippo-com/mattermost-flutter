// Converted from ./mattermost-mobile/app/utils/buttonStyles.ts

import 'package:flutter/material.dart';
import '../types/theme.dart';
import '../utils/theme.dart';

class ButtonStyles {
  static final primary = {
    'default': ButtonStyle(
      backgroundColor: WidgetStateProperty.all(theme.buttonBg),
    ),
    'hover': ButtonStyle(
      backgroundColor: WidgetStateProperty.all(blendColors(theme.buttonBg, '#000000', 0.08)),
    ),
    'active': ButtonStyle(
      backgroundColor: WidgetStateProperty.all(blendColors(theme.buttonBg, '#000000', 0.16)),
    ),
    'focus': ButtonStyle(
      backgroundColor: WidgetStateProperty.all(theme.buttonBg),
      side: WidgetStateProperty.all(BorderSide(
        color: changeOpacity('#FFFFFF', 0.32),
        width: 2,
      )),
    ),
  };

  // Similar mappings for destructive, inverted, disabled, secondary, etc.

  static ButtonStyle getBackgroundStyle({
    required Theme theme,
    String size = 'm',
    String emphasis = 'primary',
    String type = 'default',
    String state = 'default',
  }) {
    // Define styles here
    final styles = ButtonStyle(
      alignment: Alignment.center,
      shape: WidgetStateProperty.all(RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      )),
    );

    // Select the correct background style based on emphasis and type
    final backgroundStyles = ButtonStyles.primary; // This will vary based on emphasis and type

    return backgroundStyles[state]!;
  }

  static TextStyle getTextStyle({
    required Theme theme,
    String size = 'm',
    String emphasis = 'primary',
    String type = 'default',
  }) {
    // Color logic
    Color color = theme.buttonColor;

    if (type == 'disabled') {
      color = changeOpacity(theme.centerChannelColor, 0.32);
    }
    if (type == 'destructive' && emphasis != 'primary') {
      color = theme.errorTextColor;
    }
    if ((type == 'inverted' && emphasis == 'primary') || (type != 'inverted' && emphasis != 'primary')) {
      color = theme.buttonBg;
    }
    if (type == 'inverted' && emphasis == 'tertiary') {
      color = theme.sidebarText;
    }

    final styles = TextStyle(
      fontFamily: 'OpenSans-SemiBold',
      fontWeight: FontWeight.w600,
      color: color,
    );

    // Size logic
    final sizes = {
      'xs': styles.copyWith(fontSize: 11, height: 1.0, letterSpacing: 0.02),
      's': styles.copyWith(fontSize: 12, height: 1.0),
      'm': styles.copyWith(fontSize: 14, height: 1.0),
      'lg': styles.copyWith(fontSize: 16, height: 1.0),
    };

    return sizes[size]!;
  }
}
