
// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

enum LegacyThemeKey { defaultTheme, organization, mattermostDark, windows10 }

enum LegacyThemeType { Mattermost, Organization, MattermostDark, WindowsDark }

enum ThemeKey { denim, sapphire, quartz, indigo, onyx, custom }

enum ThemeType { Denim, Sapphire, Quartz, Indigo, Onyx, Custom }

class Theme {
  final ThemeType? type;
  final String sidebarBg;
  final String sidebarText;
  final String sidebarUnreadText;
  final String sidebarTextHoverBg;
  final String sidebarTextActiveBorder;
  final String sidebarTextActiveColor;
  final String sidebarHeaderBg;
  final String sidebarHeaderTextColor;
  final String sidebarTeamBarBg;
  final String onlineIndicator;
  final String awayIndicator;
  final String dndIndicator;
  final String mentionBg;
  final String mentionColor;
  final String centerChannelBg;
  final String centerChannelColor;
  final String newMessageSeparator;
  final String linkColor;
  final String buttonBg;
  final String buttonColor;
  final String errorTextColor;
  final String mentionHighlightBg;
  final String mentionHighlightLink;
  final String codeTheme;

  Theme({
    this.type,
    required this.sidebarBg,
    required this.sidebarText,
    required this.sidebarUnreadText,
    required this.sidebarTextHoverBg,
    required this.sidebarTextActiveBorder,
    required this.sidebarTextActiveColor,
    required this.sidebarHeaderBg,
    required this.sidebarHeaderTextColor,
    required this.sidebarTeamBarBg,
    required this.onlineIndicator,
    required this.awayIndicator,
    required this.dndIndicator,
    required this.mentionBg,
    required this.mentionColor,
    required this.centerChannelBg,
    required this.centerChannelColor,
    required this.newMessageSeparator,
    required this.linkColor,
    required this.buttonBg,
    required this.buttonColor,
    required this.errorTextColor,
    required this.mentionHighlightBg,
    required this.mentionHighlightLink,
    required this.codeTheme
  });
}

class ExtendedTheme extends Theme {
  final Map<String, String> extensions;

  ExtendedTheme({
    type,
    sidebarBg,
    sidebarText,
    sidebarUnreadText,
    sidebarTextHoverBg,
    sidebarTextActiveBorder,
    sidebarTextActiveColor,
    sidebarHeaderBg,
    sidebarHeaderTextColor,
    sidebarTeamBarBg,
    onlineIndicator,
    awayIndicator,
    dndIndicator,
    mentionBg,
    mentionColor,
    centerChannelBg,
    centerChannelColor,
    newMessageSeparator,
    linkColor,
    buttonBg,
    buttonColor,
    errorTextColor,
    mentionHighlightBg,
    mentionHighlightLink,
    codeTheme,
    required this.extensions
  }) : super(
    type: type,
    sidebarBg: sidebarBg,
    sidebarText: sidebarText,
    sidebarUnreadText: sidebarUnreadText,
    sidebarTextHoverBg: sidebarTextHoverBg,
    sidebarTextActiveBorder: sidebarTextActiveBorder,
    sidebarTextActiveColor: sidebarTextActiveColor,
    sidebarHeaderBg: sidebarHeaderBg,
    sidebarHeaderTextColor: sidebarHeaderTextColor,
    sidebarTeamBarBg: sidebarTeamBarBg,
    onlineIndicator: onlineIndicator,
    awayIndicator: awayIndicator,
    dndIndicator: dndIndicator,
    mentionBg: mentionBg,
    mentionColor: mentionColor,
    centerChannelBg: centerChannelBg,
    centerChannelColor: centerChannelColor,
    newMessageSeparator: newMessageSeparator,
    linkColor: linkColor,
    buttonBg: buttonBg,
    buttonColor: buttonColor,
    errorTextColor: errorTextColor,
    mentionHighlightBg: mentionHighlightBg,
    mentionHighlightLink: mentionHighlightLink,
    codeTheme: codeTheme
  );
}

class ThemeTypeMap {
  final Map<ThemeType, ThemeKey> map;

  ThemeTypeMap(this.map);
}
