import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'package:mattermost_flutter/components/compass_icon.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/typography.dart';

class HeaderRightButton {
  final bool? borderless;
  final String? buttonType;
  final String? color;
  final String iconName;
  final VoidCallback onPress;
  final double? rippleRadius;
  final String? testID;

  HeaderRightButton({
    this.borderless,
    this.buttonType,
    this.color,
    required this.iconName,
    required this.onPress,
    this.rippleRadius,
    this.testID,
  });
}

class Header extends StatelessWidget {
  final double defaultHeight;
  final bool hasSearch;
  final bool isLargeTitle;
  final double heightOffset;
  final Widget? leftComponent;
  final VoidCallback? onBackPress;
  final VoidCallback? onTitlePress;
  final List<HeaderRightButton>? rightButtons;
  final bool showBackButton;
  final String? subtitle;
  final Widget? subtitleCompanion;
  final ThemeData theme;
  final String? title;

  const Header({
    required this.defaultHeight,
    required this.hasSearch,
    required this.isLargeTitle,
    required this.heightOffset,
    this.leftComponent,
    this.onBackPress,
    this.onTitlePress,
    this.rightButtons,
    this.showBackButton = true,
    this.subtitle,
    this.subtitleCompanion,
    required this.theme,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    final insets = MediaQuery.of(context).padding;
    final styles = _getStyleSheet(theme);

    return Container(
      height: defaultHeight + insets.top,
      padding: EdgeInsets.only(top: insets.top),
      decoration: BoxDecoration(
        color: theme.sidebarBg,
      ),
      child: Row(
        children: [
          if (showBackButton)
            GestureDetector(
              onTap: onBackPress,
              child: Container(
                padding: EdgeInsets.all(20),
                child: Row(
                  children: [
                    CompassIcon(
                      size: 24,
                      name: Platform.isIOS ? 'arrow_back_ios' : 'arrow_left',
                      color: theme.sidebarHeaderTextColor,
                    ),
                    if (leftComponent != null) leftComponent!,
                  ],
                ),
              ),
            ),
          Expanded(
            child: GestureDetector(
              onTap: onTitlePress,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!hasSearch)
                    Text(
                      title ?? '',
                      style: styles['title'],
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (!isLargeTitle && (subtitle != null || subtitleCompanion != null))
                    Row(
                      children: [
                        if (subtitle != null)
                          Text(
                            subtitle!,
                            style: styles['subtitle'],
                            overflow: TextOverflow.ellipsis,
                          ),
                        if (subtitleCompanion != null) subtitleCompanion!,
                      ],
                    ),
                ],
              ),
            ),
          ),
          if (rightButtons != null)
            Row(
              children: rightButtons!.map((button) {
                return GestureDetector(
                  onTap: button.onPress,
                  child: Container(
                    padding: EdgeInsets.all(5),
                    child: CompassIcon(
                      size: 24,
                      name: button.iconName,
                      color: button.color ?? theme.sidebarHeaderTextColor,
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Map<String, TextStyle> _getStyleSheet(ThemeData theme) {
    return {
      'title': TextStyle(
        color: theme.sidebarHeaderTextColor,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      'subtitle': TextStyle(
        color: changeOpacity(theme.sidebarHeaderTextColor, 0.72),
        fontSize: 12,
        height: 1.1,
      ),
    };
  }
}
