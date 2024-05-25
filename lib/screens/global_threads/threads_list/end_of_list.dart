import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Assuming localization is set up
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/typography.dart';

class EndOfList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = useTheme(context);
    final styles = _getStyles(theme);
    final intl = AppLocalizations.of(context);

    final title = intl.threadsEndOfListTitle;
    final subtitle = intl.threadsEndOfListSubtitle;

    return Container(
      padding: EdgeInsets.only(top: 16, right: 16, left: 32),
      child: Row(
        children: [
          SvgPicture.asset('assets/illustrations/search_hint.svg'),
          Container(
            padding: EdgeInsets.only(left: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: styles['title']),
                SizedBox(height: 8),
                Text(subtitle, style: styles['subtitle']),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Map<String, TextStyle> _getStyles(ThemeData theme) {
    return {
      'title': TextStyle(
        ...typography('Heading', 300),
        color: theme.centerChannelColor,
      ),
      'subtitle': TextStyle(
        ...typography('Body', 100),
        color: theme.centerChannelColor,
      ),
    };
  }
}
