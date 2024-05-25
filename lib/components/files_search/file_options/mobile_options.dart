
import 'package:flutter/material.dart';
import 'package:mattermost_flutter/components/slide_up_panel_item.dart';
import 'package:mattermost_flutter/screens/navigation.dart';
import 'package:mattermost_flutter/utils/helpers.dart';
import 'package:mattermost_flutter/types/screens/gallery.dart';
import 'package:mattermost_flutter/types/theme.dart';

import 'header.dart';
import 'option_menus.dart';

class MobileOptionsProps {
  final FileInfo fileInfo;
  final EdgeInsets insets;
  final int numOptions;
  final Function(GalleryAction) setAction;
  final Theme theme;

  MobileOptionsProps({
    required this.fileInfo,
    required this.insets,
    required this.numOptions,
    required this.setAction,
    required this.theme,
  });
}

void showMobileOptionsBottomSheet(MobileOptionsProps props, BuildContext context) {
  Widget renderContent() {
    return Column(
      children: [
        Header(fileInfo: props.fileInfo),
        OptionMenus(
          setAction: props.setAction,
          fileInfo: props.fileInfo,
        ),
      ],
    );
  }

  bottomSheet(
    context: context,
    closeButtonId: 'close-search-file-options',
    renderContent: renderContent,
    snapPoints: [
      1,
      bottomSheetSnapPoint(props.numOptions, ITEM_HEIGHT, props.insets.bottom) + HEADER_HEIGHT,
    ],
    theme: props.theme,
    title: '',
  );
}
