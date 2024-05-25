import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter/services.dart';
import 'package:mattermost_flutter/components/formatted_text.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/typography.dart';

const SEARCH_BAR_TITLE_MARGIN_TOP = 24.0;
const SEARCH_BAR_MARGIN_TOP = 16.0;

class SelectionSearchBar extends HookWidget {
  final String term;
  final ValueChanged<String> onSearchChange;
  final ValueChanged<LayoutChangedDetails> onLayoutContainer;

  SelectionSearchBar({
    required this.term,
    required this.onSearchChange,
    required this.onLayoutContainer,
  });

  @override
  Widget build(BuildContext context) {
    final intl = useIntl();
    final theme = useTheme();
    final styles = getStyleSheet(theme);
    final isFocused = useState(false);

    void onLayoutSearchBar(LayoutChangedDetails e) {
      onLayoutContainer(e);
    }

    void onTextInputFocus() {
      isFocused.value = true;
    }

    void onTextInputBlur() {
      isFocused.value = false;
    }

    void handleSearchChange(String text) {
      onSearchChange(text);
    }

    final searchInputStyle = useMemo(() {
      final style = [styles['searchInput']];

      if (isFocused.value) {
        style.add({
          'borderWidth': 2.0,
          'borderColor': theme.buttonBg,
        });
      }

      return style;
    }, [isFocused.value, styles]);

    return Container(
      key: const Key('invite.search_bar'),
      padding: const EdgeInsets.all(0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FormattedText(
            id: 'invite.sendInvitationsTo',
            defaultMessage: 'Send invitations to…',
            style: styles['searchBarTitleText'],
            testID: 'invite.search_bar_title',
          ),
          Container(
            margin: EdgeInsets.only(top: SEARCH_BAR_MARGIN_TOP),
            child: TextField(
              autocorrect: false,
              autofocus: true,
              autocapitalize: TextCapitalization.none,
              style: TextStyle.from(searchInputStyle),
              decoration: InputDecoration(
                hintText: intl.format('invite.searchPlaceholder', 'Type a name or email address…'),
                hintStyle: TextStyle(color: styles['searchInputPlaceholder'].color),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4.0),
                  borderSide: BorderSide(
                    color: changeOpacity(theme.centerChannelColor, 0.16),
                  ),
                ),
              ),
              onChanged: handleSearchChange,
              focusNode: FocusNode(
                onKey: (node, event) {
                  if (event is RawKeyDownEvent) {
                    if (event.logicalKey == LogicalKeyboardKey.enter) {
                      handleSearchChange(term);
                      return KeyEventResult.handled;
                    }
                  }
                  return KeyEventResult.ignored;
                },
              ),
              onFocusChanged: (hasFocus) {
                if (hasFocus) {
                  onTextInputFocus();
                } else {
                  onTextInputBlur();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> getStyleSheet(Theme theme) {
    return {
      'container': BoxDecoration(
        display: 'flex',
      ),
      'searchBarTitleText': TextStyle(
        margin: const EdgeInsets.only(top: SEARCH_BAR_TITLE_MARGIN_TOP, left: 20.0, right: 20.0),
        color: theme.centerChannelColor,
        ...typography('Heading', 700, 'SemiBold'),
      ),
      'searchBar': BoxDecoration(
        margin: const EdgeInsets.only(top: SEARCH_BAR_MARGIN_TOP, left: 20.0, right: 20.0),
      ),
      'searchInput': TextStyle(
        height: 48.0,
        backgroundColor: Colors.transparent,
        ...typography('Body', 200, 'Regular'),
        lineHeight: 20.0,
        color: theme.centerChannelColor,
        borderWidth: 1.0,
        borderColor: changeOpacity(theme.centerChannelColor, 0.16),
        borderRadius: 4.0,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
      ),
      'searchInputPlaceholder': TextStyle(
        color: changeOpacity(theme.centerChannelColor, 0.64),
      ),
    };
  }
}
