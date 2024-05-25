
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';  // Ensure Platform is imported
import 'package:mattermost_flutter/hooks/android_back_handler.dart';
import 'package:mattermost_flutter/screens/navigation.dart';
import 'package:mattermost_flutter/types/screens/navigation.dart';

class TableScreen extends StatelessWidget {
  final AvailableScreens componentId;
  final bool renderAsFlex;
  final Widget Function(bool) renderRows;
  final double width;

  const TableScreen({
    Key? key,
    required this.componentId,
    required this.renderAsFlex,
    required this.renderRows,
    required this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final content = renderRows(true);
    final viewStyle = renderAsFlex ? null : BoxDecoration(width: width);

    void close() {
      popTopScreen(componentId);
    }

    useAndroidHardwareBackHandler(context, componentId, close);

    if (Platform.isAndroid) {
      return SingleChildScrollView(
        key: Key('table.screen'),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          key: Key('table.scroll_view'),
          child: renderAsFlex 
            ? Flexible(child: Container(child: content))
            : Container(
                decoration: viewStyle,
                child: content,
              ),
        ),
      );
    }

    return SafeArea(
      key: Key('table.screen'),
      child: SingleChildScrollView(
        key: Key('table.scroll_view'),
        child: Container(
          height: double.infinity,
          decoration: viewStyle,
          child: content,
        ),
      ),
    );
  }
}
