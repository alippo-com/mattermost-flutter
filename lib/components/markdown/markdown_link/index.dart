// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mattermost_flutter/constants/navigation.dart';
import 'package:mattermost_flutter/constants/screens.dart';
import 'package:mattermost_flutter/screens/navigation.dart';
import 'package:mattermost_flutter/providers/config_provider.dart';

class MarkdownLink extends StatelessWidget {
  final String url;
  final TextStyle linkStyle;

  MarkdownLink({required this.url, required this.linkStyle});

  Future<void> handlePress(BuildContext context) async {
    // Close thread view, permalink view, etc
    await dismissAllModalsAndPopToRoot(context);

    // Navigate to search screen
    Navigator.pushNamed(context, Navigation.NAVIGATE_TO_TAB, arguments: {
      'screen': Screens.SEARCH,
      'params': {
        'searchTerm': url,
      },
    });
  }

  @override
  Widget build(BuildContext context) {
    final configProvider = Provider.of<ConfigProvider>(context);
    final experimentalNormalizeMarkdownLinks = configProvider.experimentalNormalizeMarkdownLinks;
    final siteURL = configProvider.siteURL;

    // Add logic to use these config values as needed
    // For example, modify url based on experimentalNormalizeMarkdownLinks and siteURL

    return GestureDetector(
      onTap: () => handlePress(context),
      child: Text(
        url,
        style: linkStyle,
      ),
    );
  }
}

class ConfigProvider with ChangeNotifier {
  bool _experimentalNormalizeMarkdownLinks = false;
  String _siteURL = '';

  bool get experimentalNormalizeMarkdownLinks => _experimentalNormalizeMarkdownLinks;
  String get siteURL => _siteURL;

  void setConfigValues(bool normalizeLinks, String siteUrl) {
    _experimentalNormalizeMarkdownLinks = normalizeLinks;
    _siteURL = siteUrl;
    notifyListeners();
  }
}

// Usage in a parent widget
// ChangeNotifierProvider(
//   create: (_) => ConfigProvider(),
//   child: YourApp(),
// );
