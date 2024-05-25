
import 'package:flutter/material.dart';
import 'package:mattermost_flutter/components/formatted_text.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/types/typography.dart';

class EditServerHeader extends StatelessWidget {
  final Theme theme;

  EditServerHeader({required this.theme});

  @override
  Widget build(BuildContext context) {
    final styles = _getStyleSheet(theme);

    return Container(
      margin: EdgeInsets.only(bottom: 32),
      constraints: BoxConstraints(maxWidth: 600, width: double.infinity),
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          FormattedText(
            defaultMessage: 'Edit server name',
            id: 'edit_server.title',
            style: styles['title'],
            testID: 'edit_server_header.title',
          ),
          FormattedText(
            defaultMessage: 'Specify a display name for this server',
            id: 'edit_server.description',
            style: styles['description'],
            testID: 'edit_server_header.description',
          ),
        ],
      ),
    );
  }

  Map<String, TextStyle> _getStyleSheet(Theme theme) {
    return {
      'title': typography('Heading', 1000, 'SemiBold').copyWith(
        letterSpacing: -1,
        color: theme.centerChannelColor,
        margin: EdgeInsets.symmetric(vertical: 12),
      ),
      'description': typography('Body', 200, 'Regular').copyWith(
        color: changeOpacity(theme.centerChannelColor, 0.64),
      ),
    };
  }
}
