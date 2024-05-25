// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';

class SyntaxHighlight {
  final String code;
  final String language;
  final TextStyle textStyle;
  final bool selectable;

  SyntaxHighlight({
    required this.code,
    required this.language,
    required this.textStyle,
    this.selectable = false,
  });
}