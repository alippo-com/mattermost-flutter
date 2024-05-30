
import 'package:flutter/material.dart';
import 'package:mattermost_flutter/components/formatted_date.dart';
import 'package:mattermost_flutter/utils/file.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/types/file_info.dart';
import 'package:mattermost_flutter/types/typography.dart';

const String format = 'MMM DD YYYY HH:MM A';

const double HEADER_MARGIN = 8.0;
const double FILE_ICON_MARGIN = 8.0;
const double INFO_MARGIN = 8.0;
const double HEADER_HEIGHT = HEADER_MARGIN +
    ICON_SIZE +
    FILE_ICON_MARGIN +
    (28.0 * 2.0) + //400 line height times two lines
    (INFO_MARGIN * 2.0) +
    24.0; // 200 line height

class Header extends StatelessWidget {
  final FileInfo fileInfo;

  const Header({required this.fileInfo});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = _getStyleSheet(theme);

    final size = getFormattedFileSize(fileInfo.size);

    return Container(
      margin: EdgeInsets.only(bottom: HEADER_MARGIN),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(bottom: FILE_ICON_MARGIN),
            alignment: Alignment.topLeft,
            child: Icon(fileInfo: fileInfo),
          ),
          Text(
            fileInfo.name,
            style: style['nameText'],
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          Container(
            margin: EdgeInsets.symmetric(vertical: INFO_MARGIN),
            alignment: Alignment.center,
            child: Row(
              children: [
                Text(
                  '$size • ',
                  style: style['infoText'],
                ),
                FormattedDate(
                  format: format,
                  value: fileInfo.createAt,
                  style: style['date'],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Map<String, TextStyle> _getStyleSheet(ThemeData theme) {
    return {
      'nameText': TextStyle(
        color: theme.centerChannelColor,
        ...typography('Heading', 400, 'SemiBold'),
      ),
      'infoText': TextStyle(
        color: changeOpacity(theme.centerChannelColor, 0.64),
        ...typography('Body', 200, 'Regular'),
      ),
      'date': TextStyle(
        color: changeOpacity(theme.centerChannelColor, 0.64),
        ...typography('Body', 200, 'Regular'),
      ),
    };
  }
}
