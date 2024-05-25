
import 'package:flutter/material.dart';
import 'package:mattermost_flutter/constants/view.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/hooks/header.dart';
import 'package:mattermost_flutter/utils/gallery.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/components/header.dart';
import 'package:mattermost_flutter/components/navigation_header_large_title.dart';
import 'package:mattermost_flutter/components/navigation_search.dart';
import 'package:mattermost_flutter/types/search_props.dart';
import 'package:mattermost_flutter/types/search_ref.dart';

class NavigationHeader extends StatefulWidget {
  final bool hasSearch;
  final bool isLargeTitle;
  final Widget? leftComponent;
  final VoidCallback? onBackPress;
  final VoidCallback? onTitlePress;
  final List<HeaderRightButton>? rightButtons;
  final ValueNotifier<double>? scrollValue;
  final ValueNotifier<double?>? lockValue;
  final VoidCallback? hideHeader;
  final bool showBackButton;
  final String? subtitle;
  final Widget? subtitleCompanion;
  final String title;

  const NavigationHeader({
    Key? key,
    this.hasSearch = false,
    this.isLargeTitle = false,
    this.leftComponent,
    this.onBackPress,
    this.onTitlePress,
    this.rightButtons,
    this.scrollValue,
    this.lockValue,
    this.hideHeader,
    this.showBackButton = true,
    this.subtitle,
    this.subtitleCompanion,
    this.title = '',
  }) : super(key: key);

  @override
  _NavigationHeaderState createState() => _NavigationHeaderState();
}

class _NavigationHeaderState extends State<NavigationHeader> {
  late ThemeData theme;
  late double largeHeight;
  late double defaultHeight;
  late double headerOffset;

  @override
  void initState() {
    super.initState();
    theme = useTheme();
    final headerData = useHeaderHeight();
    largeHeight = headerData.largeHeight;
    defaultHeight = headerData.defaultHeight;
    headerOffset = headerData.headerOffset;
  }

  @override
  Widget build(BuildContext context) {
    final containerHeight = ValueListenableBuilder<double?>(
      valueListenable: widget.scrollValue ?? ValueNotifier<double>(0),
      builder: (context, value, child) {
        final calculatedHeight = (widget.isLargeTitle ? largeHeight : defaultHeight) - (value ?? 0);
        final height = widget.lockValue?.value ?? calculatedHeight;
        return {
          'height': height.clamp(defaultHeight, largeHeight + MAX_OVERSCROLL),
          'minHeight': defaultHeight,
          'maxHeight': largeHeight + MAX_OVERSCROLL,
        };
      },
    );

    final translateY = ValueListenableBuilder<double?>(
      valueListenable: widget.lockValue ?? ValueNotifier<double>(0),
      builder: (context, value, child) {
        return value ?? 0;
      },
    );

    final searchTopStyle = ValueListenableBuilder<double?>(
      valueListenable: widget.scrollValue ?? ValueNotifier<double>(0),
      builder: (context, value, child) {
        final margin = clamp(-value!, -headerOffset, headerOffset);
        final marginTop = (widget.lockValue?.value ?? margin) - SEARCH_INPUT_HEIGHT - SEARCH_INPUT_MARGIN;
        return {'marginTop': marginTop};
      },
    );

    final heightOffset = ValueListenableBuilder<double?>(
      valueListenable: widget.lockValue ?? ValueNotifier<double>(0),
      builder: (context, value, child) {
        return value ?? headerOffset;
      },
    );

    return AnimatedContainer(
      duration: Duration(milliseconds: 250),
      child: Column(
        children: [
          Header(
            defaultHeight: defaultHeight,
            hasSearch: widget.hasSearch,
            isLargeTitle: widget.isLargeTitle,
            heightOffset: heightOffset.value,
            leftComponent: widget.leftComponent,
            onBackPress: widget.onBackPress,
            onTitlePress: widget.onTitlePress,
            rightButtons: widget.rightButtons,
            lockValue: widget.lockValue,
            scrollValue: widget.scrollValue,
            showBackButton: widget.showBackButton,
            subtitle: widget.subtitle,
            subtitleCompanion: widget.subtitleCompanion,
            theme: theme,
            title: widget.title,
          ),
          if (widget.isLargeTitle)
            NavigationHeaderLargeTitle(
              heightOffset: heightOffset.value,
              hasSearch: widget.hasSearch,
              subtitle: widget.subtitle,
              theme: theme,
              title: widget.title,
              translateY: translateY.value,
            ),
          if (widget.hasSearch)
            NavigationSearch(
              hideHeader: widget.hideHeader,
              theme: theme,
              topStyle: searchTopStyle.value,
            ),
        ],
      ),
    );
  }
}
