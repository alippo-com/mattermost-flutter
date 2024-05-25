import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DisabledFields extends StatelessWidget {
  final bool isTablet;

  DisabledFields({this.isTablet = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textStyle = TextStyle(
      fontSize: 16.0, // Assuming 'Body' style with size 75 corresponds to 16.0
      color: theme.textTheme.bodyText1!.color!.withOpacity(0.5),
    );

    final containerPadding = isTablet ? 42.0 : 20.0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: containerPadding),
      child: Column(
        children: [
          SizedBox(height: 16.0),
          Text(
            Intl.message(
              'Some fields below are handled through your login provider. If you want to change them, you’ll need to do so through your login provider.',
              name: 'fieldHandledExternally',
              desc: 'Message explaining that some fields are handled externally',
            ),
            style: textStyle,
          ),
        ],
      ),
    );
  }
}
