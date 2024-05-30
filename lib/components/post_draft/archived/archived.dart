import 'package:flutter/material.dart';
import 'package:mattermost_flutter/constants/general.dart';
import 'package:mattermost_flutter/components/formatted_markdown_text.dart';
import 'package:mattermost_flutter/components/formatted_text.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/typography.dart';
import 'package:mattermost_flutter/hooks/server.dart';
import 'package:mattermost_flutter/actions/remote/channel.dart';
import 'package:mattermost_flutter/i18n.dart';

class Archived extends StatelessWidget {
  final String? testID;
  final bool? deactivated;

  const Archived({
    Key? key,
    this.testID,
    this.deactivated,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = _getStyleSheet(theme);
    final isTablet = useIsTablet();
    final serverUrl = useServerUrl();

    void onCloseChannelPress() {
      if (isTablet) {
        switchToPenultimateChannel(serverUrl);
      } else {
        popToRoot();
      }
    }

    var message = {
      'id': t('archivedChannelMessage'),
      'defaultMessage': 'You are viewing an **archived channel**. New messages cannot be posted.',
    };

    if (deactivated == true) {
      message = {
        'id': t('create_post.deactivated'),
        'defaultMessage': 'You are viewing an archived channel with a deactivated user.',
      };
    }

    return SafeArea(
      bottom: true,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border(
            top: BorderSide(color: changeOpacity(theme.dividerColor, 0.20)),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FormattedMarkdownText(
              message,
              style: style['archivedText']!,
              baseTextStyle: style['baseTextStyle']!,
              location: '',
            ),
            SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                padding: EdgeInsets.symmetric(vertical: 5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                minimumSize: Size(double.infinity, 40),
              ),
              onPressed: onCloseChannelPress,
              child: Text(
                t('center_panel.archived.closeChannel'),
                style: style['closeButtonText'],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, TextStyle> _getStyleSheet(ThemeData theme) {
    return {
      'archivedWrapper': TextStyle(
        paddingHorizontal: 20,
        paddingVertical: 10,
        borderTopWidth: 1,
        backgroundColor: theme.colorScheme.surface,
        borderTopColor: changeOpacity(theme.dividerColor, 0.20),
      ),
      'baseTextStyle': typography('Body', 200, 'Regular').copyWith(
        color: theme.textTheme.bodyLarge!.color,
      ),
      'archivedText': TextStyle(
        textAlign: TextAlign.center,
        color: theme.textTheme.bodyLarge!.color,
      ),
      'closeButtonText': TextStyle(
        marginTop: 7,
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    };
  }
}
