import 'package:flutter/material.dart';
import 'package:flutter_math_view/flutter_math_view.dart';
import 'package:mattermost_flutter/components/formatted_text.dart';
import 'package:mattermost_flutter/components/markdown/error_boundary.dart';
import 'package:mattermost_flutter/components/slide_up_panel_item.dart';
import 'package:mattermost_flutter/components/touchable_with_feedback.dart';
import 'package:mattermost_flutter/constants.dart';
import 'package:mattermost_flutter/screens/navigation.dart';
import 'package:mattermost_flutter/utils/helpers.dart';
import 'package:mattermost_flutter/utils/markdown.dart';
import 'package:mattermost_flutter/utils/tap.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/typography.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_safe_area/flutter_safe_area.dart';

const int MAX_LINES = 2;

class LatexCodeBlock extends HookWidget {
  final String content;
  final ThemeData theme;

  LatexCodeBlock({required this.content, required this.theme});

  @override
  Widget build(BuildContext context) {
    final intl = useIntl();
    final bottom = useSafeAreaInsets().bottom;
    final managedConfig = useManagedConfig<ManagedConfig>();
    final styles = getStyleSheet(theme);
    final languageDisplayName = getHighlightLanguageName('latex');

    List<String> splitLines = useMemo(() {
      final lines = splitLatexCodeInLines(content);
      final numberOfLines = lines.length;

      if (numberOfLines > MAX_LINES) {
        return lines.sublist(0, MAX_LINES);
      }

      return lines;
    }, [content]);

    void handlePress() {
      final screen = Screens.LATEX;
      final passProps = {
        'content': content,
      };
      final title = intl.formatMessage(
        id: 'mobile.routes.code',
        defaultMessage: '{language} Code',
        args: {'language': languageDisplayName},
      );

      KeyboardVisibilityController.instance.onChange.listen((visible) {
        if (!visible) {
          goToScreen(screen, title, passProps);
        }
      });
    }

    void handleLongPress() {
      if (managedConfig?.copyAndPasteProtection != 'true') {
        final renderContent = () {
          return Column(
            children: [
              SlideUpPanelItem(
                leftIcon: Icons.content_copy,
                onPress: () {
                  dismissBottomSheet();
                  Clipboard.setData(ClipboardData(text: content));
                },
                text: intl.formatMessage(
                    id: 'mobile.markdown.code.copy_code',
                    defaultMessage: 'Copy Code'),
              ),
              SlideUpPanelItem(
                destructive: true,
                leftIcon: Icons.cancel,
                onPress: dismissBottomSheet,
                text: intl.formatMessage(
                    id: 'mobile.post.cancel', defaultMessage: 'Cancel'),
              ),
            ],
          );
        };

        bottomSheet(
          closeButtonId: 'close-code-block',
          renderContent: renderContent,
          snapPoints: [1, bottomSheetSnapPoint(2, ITEM_HEIGHT, bottom)],
          title: intl.formatMessage(
              id: 'post.options.title', defaultMessage: 'Options'),
          theme: theme,
        );
      }
    }

    Widget onRenderErrorMessage(Error error) {
      return Text('Render error: ${error.message}', style: styles.errorText);
    }

    Widget plusMoreLines = Container();
    if (splitLines.length > MAX_LINES) {
      plusMoreLines = FormattedText(
        style: styles.plusMoreLinesText,
        id: 'mobile.markdown.code.plusMoreLines',
        defaultMessage: '+{count, number} more {count, plural, one {line} other {lines}}',
        values: {'count': splitLines.length - MAX_LINES},
      );
    }

    return TouchableWithFeedback(
      onPress: handlePress,
      onLongPress: handleLongPress,
      type: TouchableFeedbackType.opacity,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: changeOpacity(theme.centerChannelColor, 0.15),
            width: 0.5,
          ),
          borderRadius: BorderRadius.circular(3),
        ),
        child: Row(
          children: [
            ErrorBoundary(
              error: intl.formatMessage(
                  id: 'markdown.latex.error',
                  defaultMessage: 'Latex render error'),
              theme: theme,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: splitLines.map((latexCode) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Math.tex(
                      latexCode,
                      textStyle: TextStyle(color: theme.centerChannelColor),
                      onErrorFallback: (err) => onRenderErrorMessage(err),
                    ),
                  );
                }).toList(),
              ),
            ),
            plusMoreLines,
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                color: theme.sidebarHeaderBg,
                padding: const EdgeInsets.all(6),
                child: Text(
                  languageDisplayName,
                  style: TextStyle(color: theme.sidebarHeaderTextColor),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  ThemeData getStyles(ThemeData theme) {
    final codeVerticalPadding = Platform.isIOS ? 4.0 : 0.0;

    return ThemeData(
      textTheme: theme.textTheme.copyWith(
        bodyText1: theme.textTheme.bodyText1.copyWith(
          color: changeOpacity(theme.centerChannelColor, 0.4),
          fontSize: 14,
          fontWeight: FontWeight.w400,
          marginTop: 2,
        ),
      ),
      primaryColor: theme.primaryColor,
      accentColor: theme.accentColor,
    ).copyWith(
      primaryTextTheme: theme.textTheme.copyWith(
        bodyText1: theme.textTheme.bodyText1.copyWith(
          color: theme.errorTextColor,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          marginHorizontal: 5,
        ),
      ),
      scaffoldBackgroundColor: theme.scaffoldBackgroundColor,
    );
  }
}
