// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mattermost_flutter/components/search_bar.dart';
import 'package:mattermost_flutter/hooks/device.dart';
import 'package:mattermost_flutter/hooks/emoji_category_bar.dart';

import 'bottom_sheet_search.dart';
import 'skintone_selector.dart';

class PickerHeader extends StatelessWidget {
  final String skinTone;
  final SearchProps props;

  PickerHeader({required this.skinTone, required this.props});

  @override
  Widget build(BuildContext context) {
    final isTablet = useIsTablet();
    final containerWidth = ValueNotifier<double>(0);
    final isSearching = ValueNotifier<bool>(false);

    useEffect(() {
      final req = requestAnimationFrame(() {
        setEmojiSkinTone(skinTone);
      });

      return () => cancelAnimationFrame(req);
    }, [skinTone]);

    void onBlur() {
      isSearching.value = false;
    }

    void onFocus() {
      isSearching.value = true;
    }

    void onLayout(Size size) {
      containerWidth.value = size.width;
    }

    Widget search;
    if (isTablet) {
      search = SearchBar(
        props: props,
        onBlur: onBlur,
        onFocus: onFocus,
      );
    } else {
      search = BottomSheetSearch(
        props: props,
        onBlur: onBlur,
        onFocus: onFocus,
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        onLayout(constraints.biggest);
        return Row(
          children: [
            Expanded(
              child: search,
            ),
            SkinToneSelector(
              skinTone: skinTone,
              containerWidth: containerWidth,
              isSearching: isSearching,
            ),
          ],
        );
      },
    );
  }
}

// Define the SearchProps class if it is not already defined
class SearchProps {
  // Add required properties and methods for SearchProps
}
