import 'package:flutter/material.dart';
import 'package:mattermost_flutter/types/theme.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/components/loading.dart';

class Loader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Container(
        margin: EdgeInsets.all(-18),
        child: Loading(
          color: theme.buttonBg,
          size: 50.0, // Equivalent to 'large' in Flutter
        ),
      ),
    );
  }
}
