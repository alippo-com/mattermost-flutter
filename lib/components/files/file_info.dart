
// Dart Code
// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:mattermost_flutter/types/file_info.dart';
import 'package:mattermost_flutter/components/formatted_date.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/utils/file.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/typography.dart';

class FileInfoProps {
  final FileInfo file;
  final bool showDate;
  final String? channelName;
  final VoidCallback onPress;

  FileInfoProps({
    required this.file,
    required this.showDate,
    this.channelName,
    required this.onPress,
  });
}

const FORMAT = ' • MMM dd HH:mm a';

class FileInfo extends StatelessWidget {
  final FileInfoProps props;

  const FileInfo({Key? key, required this.props}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = useTheme(context);
    final style = _getStyleSheet(theme);

    return Container(
      child: GestureDetector(
        onTap: props.onPress,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              props.file.name.trim(),
              style: style['fileName'],
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Row(
              children: [
                if (props.channelName != null)
                  Container(
                    decoration: BoxDecoration(
                      color: changeOpacity(theme.centerChannelColor, 0.08),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    margin: EdgeInsets.only(right: 4),
                    child: Text(
                      props.channelName!,
                      style: style['channelText'],
                      maxLines: 1,
                    ),
                  ),
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        getFormattedFileSize(props.file.size),
                        style: style['infoText'],
                      ),
                      if (props.showDate)
                        FormattedDate(
                          format: FORMAT,
                          value: DateTime.fromMillisecondsSinceEpoch(props.file.createAt),
                          style: style['infoText'],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Map<String, TextStyle> _getStyleSheet(ThemeData theme) {
    return {
      'fileName': typography('Body', 200, 'SemiBold').copyWith(
        color: theme.centerChannelColor,
        paddingRight: 10,
      ),
      'infoText': typography('Body', 75, 'Regular').copyWith(
        color: changeOpacity(theme.centerChannelColor, 0.64),
      ),
      'channelText': typography('Body', 50, 'SemiBold').copyWith(
        color: changeOpacity(theme.centerChannelColor, 0.72),
      ),
    };
  }
}
