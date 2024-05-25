
import 'package:flutter/material.dart';
import 'package:mattermost_flutter/components/formatted_text.dart';
import 'package:mattermost_flutter/components/no_results_with_term/search_files_illustration.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/types.dart'; // Assuming typography is defined here

const TEST_ID = 'channel_files';

class NoResults extends StatelessWidget {
  final bool? isFilterEnabled;

  NoResults({this.isFilterEnabled});

  @override
  Widget build(BuildContext context) {
    final theme = useTheme(context);
    final styles = getStyleSheet(theme);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 32),
      height: double.infinity,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SearchFilesIllustration(),
          if (!isFilterEnabled!) ...[
            FormattedText(
              defaultMessage: 'No files yet',
              id: 'channel_files.empty.title',
              style: styles['title'],
              testID: '$TEST_ID.empty.title',
            ),
            SizedBox(height: 8),
            FormattedText(
              defaultMessage: 'Files posted in this channel will show here.',
              id: 'channel_files.empty.paragraph',
              style: styles['paragraph'],
              testID: '$TEST_ID.empty.paragraph',
            ),
          ],
          if (isFilterEnabled!) ...[
            FormattedText(
              defaultMessage: 'No files Found',
              id: 'channel_files.noFiles.title',
              style: styles['title'],
              testID: '$TEST_ID.empty.title',
            ),
            SizedBox(height: 8),
            FormattedText(
              defaultMessage: 'This channel doesn't contain any files with the applied filters',
              id: 'channel_files.noFiles.paragraph',
              style: styles['paragraph'],
              testID: '$TEST_ID.empty.paragraph',
            ),
          ],
        ],
      ),
    );
  }

  Map<String, TextStyle> getStyleSheet(ThemeData theme) {
    return {
      'title': TextStyle(
        color: theme.centerChannelColor,
        fontWeight: FontWeight.w600, // Assuming SemiBold is equivalent to w600
        fontSize: 24, // Assuming 'Heading' with size 400 maps to 24
      ),
      'paragraph': TextStyle(
        color: theme.centerChannelColor.withOpacity(0.72),
        fontSize: 14, // Assuming 'Body' with size 200 maps to 14
      ),
    };
  }
}

TextStyle changeOpacity(Color color, double opacity) {
  return TextStyle(color: color.withOpacity(opacity));
}
