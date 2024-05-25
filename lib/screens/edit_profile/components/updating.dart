
import 'package:flutter/material.dart';
import 'package:mattermost_flutter/components/loading.dart'; // Adjust the path as necessary
import 'package:mattermost_flutter/context/theme.dart'; // Adjust the path as necessary

class Updating extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = useTheme(context);

    return Container(
      width: double.infinity,
      height: double.infinity,
      alignment: Alignment.center,
      child: Loading(
        color: theme.buttonBg,
      ),
    );
  }
}
