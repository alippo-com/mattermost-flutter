
import 'package:flutter/material.dart';
import 'package:mattermost_flutter/managers/apps_manager.dart';
import 'package:rxdart/rxdart.dart';

class OwnProps {
  final String? serverUrl;
  OwnProps({this.serverUrl});
}

class EnhancedAutocomplete extends StatelessWidget {
  final OwnProps props;
  const EnhancedAutocomplete({required this.props});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: props.serverUrl != null 
          ? AppsManager.observeIsAppsEnabled(props.serverUrl!) 
          : Stream.value(false),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!) {
          return Autocomplete();
        } else {
          return Container(); // Return an empty container or a fallback widget
        }
      },
    );
  }
}

class Autocomplete extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Build your Autocomplete widget here
    return Container();
  }
}
