// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'dart:ui';
import 'dart:io';

List<double> getLabelPositions(TextStyle style, TextStyle labelStyle, TextStyle smallLabelStyle) {
  final double textInputFontSize = style.fontSize ?? 13.0;
  final double labelFontSize = labelStyle.fontSize ?? 16.0;
  final double smallLabelFontSize = smallLabelStyle.fontSize ?? 10.0;
  final double fontSizeDiff = textInputFontSize - labelFontSize;
  
  // Calculate height based on available properties.
  final double height = style.height ?? 0.0;

  final double unfocused = (height * 0.5) + (fontSizeDiff * (Platform.isAndroid ? 0.5 : 0.6));
  final double focused = -(labelFontSize + smallLabelFontSize) * 0.25;
  return [unfocused, focused];
}
