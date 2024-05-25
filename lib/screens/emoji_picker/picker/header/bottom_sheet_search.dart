// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:mattermost_flutter/components/search.dart'; // Assuming a similar search component exists in Flutter

class BottomSheetSearch extends StatelessWidget {
  final Function(FocusNode)? onFocus;
  final SearchProps props;

  BottomSheetSearch({this.onFocus, required this.props});

  @override
  Widget build(BuildContext context) {
    final FocusNode focusNode = FocusNode();

    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        // Example expand logic
        _expandBottomSheet();
        onFocus?.call(focusNode);
      }
    });

    return SearchBar(
      focusNode: focusNode,
      props: props,
    );
  }

  void _expandBottomSheet() {
    // Add the actual expand logic here
    print('Bottom sheet expanded');
  }
}
