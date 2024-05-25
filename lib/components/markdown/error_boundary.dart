// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';

class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final String error;
  final ThemeData theme;

  ErrorBoundary({required this.child, required this.error, required this.theme});

  @override
  _ErrorBoundaryState createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  bool hasError = false;

  @override
  void didUpdateWidget(covariant ErrorBoundary oldWidget) {
    super.didUpdateWidget(oldWidget);

    setState(() {
      hasError = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (hasError) {
      return Text(
        widget.error,
        style: getErrorStyle(widget.theme),
      );
    }

    return widget.child;
  }
}

TextStyle getErrorStyle(ThemeData theme) {
  return TextStyle(
    color: theme.errorColor,
    fontStyle: FontStyle.italic,
    // Add other styles based on your typographic settings
  );
}
