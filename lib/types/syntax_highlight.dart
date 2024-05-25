
// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:mattermost_flutter/types/text_style.dart'; // Assuming custom TextStyle is defined here

/// Represents the properties for the syntax highlight component.
class SyntaxHighlightProps {
  final String code;
  final String language;
  final TextStyle textStyle;
  final bool selectable;

  /// Creates a new instance of SyntaxHighlightProps.
  /// 
  /// * [code]: The code to be highlighted.
  /// * [language]: The programming language of the code.
  /// * [textStyle]: The text style to apply to the highlighted code.
  /// * [selectable]: Whether the text can be selected. Defaults to false.
  SyntaxHighlightProps({
    required this.code,
    required this.language,
    required this.textStyle,
    this.selectable = false,
  });
}
