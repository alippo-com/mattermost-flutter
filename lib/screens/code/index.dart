
import 'package:flutter/material.dart';
import 'package:flutter_safe_area/flutter_safe_area.dart';

import 'package:mattermost_flutter/components/syntax_highlight.dart';

import 'package:mattermost_flutter/types.dart'; // For the Theme type

class Code extends StatelessWidget {
  final String componentId;
  final String code;
  final String language;
  final TextStyle textStyle;

  Code({
    required this.componentId,
    required this.code,
    required this.language,
    required this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final managedConfig = useManagedConfig(); // Adjust this to match your config management in Flutter
    useAndroidHardwareBackHandler(componentId, popTopScreen);

    return SafeArea(
      left: true,
      top: false,
      right: true,
      bottom: false,
      child: Container(
        flex: 1,
        child: SyntaxHighlight(
          code: code,
          language: language,
          selectable: managedConfig.copyAndPasteProtection != 'true',
          textStyle: textStyle,
        ),
      ),
    );
  }
}
