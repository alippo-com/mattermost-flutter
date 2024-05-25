// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:mattermost_flutter/components/formatted_text.dart';
import 'package:mattermost_flutter/components/slide_up_panel_item.dart';
import 'package:mattermost_flutter/constants.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/screens/navigation.dart';
import 'package:mattermost_flutter/utils/helpers.dart';
import 'package:mattermost_flutter/utils/markdown.dart';
import 'package:mattermost_flutter/utils/tap.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/types/syntax_highlight.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

class MarkdownCodeBlock extends HookWidget {
  final String language;
  final String content;
  final TextStyle textStyle;

  MarkdownCodeBlock({this.language = '', required this.content, required this.textStyle});

  static const MAX_LINES = 4;

  @override
  Widget build(BuildContext context) {
    final theme = useTheme();
    final style = _getStyleSheet(theme);
    final syntaxHighlighter = useMemo(
      () => getSyntaxHighlighter(),
      [],
    );

    void handlePress() {
      final screen = Screens.CODE;
      final passProps = {
        'code': content,
        'language': getHighlightLanguageFromNameOrAlias(language),
        'textStyle': textStyle,
      };

      final languageDisplayName = getHighlightLanguageName(language);
      final title = languageDisplayName != null
          ? '${languageDisplayName} Code'
          : 'Code';

      KeyboardVisibilityController().hide();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        goToScreen(context, screen, title, passProps);
      });
    }

    void handleLongPress() {
      if (useManagedConfig().copyAndPasteProtection != 'true') {
        void renderContent() {
          return Column(
            children: [
              SlideUpPanelItem(
                leftIcon: Icons.content_copy,
                onPress: () {
                  dismissBottomSheet(context);
                  Clipboard.setData(ClipboardData(text: content));
                },
                text: 'Copy Code',
              ),
              SlideUpPanelItem(
                destructive: true,
                leftIcon: Icons.cancel,
                onPress: () {
                  dismissBottomSheet(context);
                },
                text: 'Cancel',
              ),
            ],
          );
        }

        bottomSheet(
          context: context,
          renderContent: renderContent,
          snapPoints: [1, bottomSheetSnapPoint(2, ITEM_HEIGHT, MediaQuery.of(context).padding.bottom)],
          title: 'Options',
          theme: theme,
        );
      }
    }

    String trimContent(String text) {
      final lines = text.split('
');
      final numberOfLines = lines.length;

      if (numberOfLines > MAX_LINES) {
        return lines.sublist(0, MAX_LINES).join('
');
      }

      return text;
    }

    Widget renderLanguageBlock() {
      if (language.isNotEmpty) {
        final languageDisplayName = getHighlightLanguageName(language);

        if (languageDisplayName != null) {
          return Container(
            alignment: Alignment.center,
            color: theme.sidebarHeaderBg,
            padding: const EdgeInsets.all(6),
            child: Text(
              languageDisplayName,
              style: TextStyle(color: theme.sidebarHeaderTextColor, fontSize: 12),
            ),
          );
        }
      }
      return Container();
    }

    final codeContent = trimContent(content);
    final numberOfLines = content.split('
').length;

    Widget renderPlusMoreLines() {
      if (numberOfLines > MAX_LINES) {
        return FormattedText(
          text: '+${numberOfLines - MAX_LINES} more lines',
          style: TextStyle(color: changeOpacity(theme.centerChannelColor, 0.4), fontSize: 11, marginTop: 2),
        );
      }
      return Container();
    }

    return GestureDetector(
      onTap: handlePress,
      onLongPress: handleLongPress,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: changeOpacity(theme.centerChannelColor, 0.15), width: 0.5),
          borderRadius: BorderRadius.circular(3),
          flexDirection: 'row',
        ),
        child: Column(
          children: [
            Container(
              child: syntaxHighlighter(
                code: codeContent,
                language: getHighlightLanguageFromNameOrAlias(language),
                textStyle: textStyle,
              ),
            ),
            renderPlusMoreLines(),
            renderLanguageBlock(),
          ],
        ),
      ),
    );
  }

  Widget Function({required String code, required String language, required TextStyle textStyle}) getSyntaxHighlighter() {
    // Implement your syntax highlighter here
    throw UnimplementedError();
  }

  Map<String, dynamic> _getStyleSheet(Theme theme) {
    return {
      'bottomSheet': {
        'flex': 1,
      },
      'container': {
        'borderColor': changeOpacity(theme.centerChannelColor, 0.15),
        'borderRadius': 3,
        'borderWidth': 0.5,
        'flexDirection': 'row',
      },
      'code': {
        'flexDirection': 'row',
        'overflow': 'scroll', // Doesn't actually cause a scrollbar, but stops text from wrapping
      },
      'plusMoreLinesText': {
        'color': changeOpacity(theme.centerChannelColor, 0.4),
        'fontSize': 11,
        'marginTop': 2),
      },
      'language': {
        'alignItems': 'center',
        'backgroundColor': theme.sidebarHeaderBg,
        'justifyContent': 'center',
        'opacity': 0.8,
        'padding': 6,
        'position': 'absolute',
        'right': 0,
        'top': 0,
      },
      'languageText': {
        'color': theme.sidebarHeaderTextColor,
        'fontSize': 12,
      },
    };
  }
}
