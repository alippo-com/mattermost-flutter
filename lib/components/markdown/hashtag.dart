// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:mattermost_flutter/constants/navigation.dart';
import 'package:mattermost_flutter/constants/screens.dart';
import 'package:mattermost_flutter/screens/navigation.dart';

class Hashtag extends StatelessWidget {
  final String hashtag;
  final TextStyle linkStyle;

  Hashtag({required this.hashtag, required this.linkStyle});

  Future<void> handlePress(BuildContext context) async {
    // Close thread view, permalink view, etc
    await dismissAllModalsAndPopToRoot(context);

    // Navigate to search screen
    Navigator.pushNamed(context, Navigation.NAVIGATE_TO_TAB, arguments: {
      'screen': Screens.SEARCH,
      'params': {
        'searchTerm': '#$hashtag',
      },
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => handlePress(context),
      child: Text(
        '#$hashtag',
        style: linkStyle,
      ),
    );
  }
}
