// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:mattermost_flutter/types.dart';

void onExecution(
    MethodCall e,
    void Function()? innerFunc,
    void Function(MethodCall event)? outerFunc,
) {
    innerFunc?.call();
    outerFunc?.call(e);
}

List<double> getLabelPositions(
    TextStyle style,
    TextStyle labelStyle,
    TextStyle smallLabelStyle,
) {
    double top = style.padding?.top ?? 0;
    double bottom = style.padding?.bottom ?? 0;

    double height = (style.height ?? (top + bottom) ?? style.padding?.vertical) ?? 0;
    double textInputFontSize = style.fontSize ?? 13;
    double labelFontSize = labelStyle.fontSize ?? 16;
    double smallLabelFontSize = smallLabelStyle.fontSize ?? 10;
    double fontSizeDiff = textInputFontSize - labelFontSize;
    double unfocused = (height * 0.5) + (fontSizeDiff * (defaultTargetPlatform == TargetPlatform.android ? 0.5 : 0.6));
    double focused = -(labelFontSize + smallLabelFontSize) * 0.25;
    return [unfocused, focused];
}