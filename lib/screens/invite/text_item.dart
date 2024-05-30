dart
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:mattermost_flutter/components/compass_icon.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/typography.dart';

enum TextItemType {
  searchInvite,
  searchNoResults,
  summary,
}

class TextItem extends HookWidget {
  final String text;
  final TextItemType type;
  final String testID;

  TextItem({
    required this.text,
    required this.type,
    required this.testID,
  });

  @override
  Widget build(BuildContext context) {
    final intl = useIntl();
    final theme = useTheme();
    final styles = getStyleSheet(theme);

    final search = type == TextItemType.searchInvite || type == TextItemType.searchNoResults;
    final email = type == TextItemType.searchInvite || type == TextItemType.summary;

    return Container(
      padding: EdgeInsets.symmetric(vertical: search ? 8.0 : 0),
      child: Row(
        children: [
          if (email)
            Container(
              height: 24,
              width: 24,
              decoration: BoxDecoration(
                color: theme.centerChannelColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              margin: EdgeInsets.only(right: 12),
              child: Center(
                child: CompassIcon(
                  name: search ? 'email-plus-outline' : 'email-outline',
                  size: 14,
                  color: theme.centerChannelColor.withOpacity(0.56),
                ),
              ),
            ),
          if (search)
            Text(
              email ? intl.format('invite.search.email_invite') : intl.format('invite.search.no_results'),
              style: typography('Body', 200, 'Regular').copyWith(color: theme.centerChannelColor),
              maxLines: 1,
            ),
          Text(
            text,
            style: search
                ? typography('Body', 200, 'SemiBold').copyWith(color: theme.centerChannelColor)
                : typography('Body', 200, 'Regular').copyWith(color: theme.centerChannelColor),
            maxLines: 1,
            flex: 1,
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> getStyleSheet(Theme theme) {
    return {
      'item': BoxDecoration(
        display: 'flex',
        flexDirection: 'row',
        alignItems: 'center',
      ),
      'search': BoxDecoration(
        height: 40,
        paddingVertical: 8,
      ),
      'itemText': TextStyle(
        display: 'flex',
        ...typography('Body', 200, 'Regular'),
        color: theme.centerChannelColor,
      ),
      'itemTerm': TextStyle(
        display: 'flex',
        ...typography('Body', 200, 'SemiBold'),
        color: theme.centerChannelColor,
        marginLeft: 4,
      ),
      'itemImage': BoxDecoration(
        alignItems: 'center',
        justifyContent: 'center',
        height: 24,
        width: 24,
        borderRadius: 12,
        backgroundColor: theme.centerChannelColor.withOpacity(0.08),
        marginRight: 12,
      ),
      'itemIcon': TextStyle(
        color: theme.centerChannelColor.withOpacity(0.56),
      ),
    };
  }
}
