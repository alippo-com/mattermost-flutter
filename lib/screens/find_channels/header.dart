
import 'package:flutter/material.dart';
import 'package:mattermost_flutter/types/theme.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/typography.dart';

class FindChannelsHeader extends StatelessWidget {
  final String sectionName;

  FindChannelsHeader({required this.sectionName});

  @override
  Widget build(BuildContext context) {
    final theme = useTheme(context);
    final styles = _getStyleSheet(theme);

    return Container(
      padding: EdgeInsets.only(top: 12, left: 2, bottom: 8),
      alignment: Alignment.topLeft,
      color: theme.centerChannelBg,
      child: Text(
        sectionName.toUpperCase(),
        style: styles.heading,
        key: Key('find_channels.header.$sectionName'),
      ),
    );
  }

  _StyleSheet _getStyleSheet(Theme theme) {
    return _StyleSheet(
      container: BoxDecoration(
        color: theme.centerChannelBg,
      ),
      heading: TextStyle(
        color: changeOpacity(theme.centerChannelColor, 0.64),
        textTransform: TextTransform.uppercase,
        ...typography('Heading', 75, FontWeight.w600),
      ),
    );
  }
}

class _StyleSheet {
  final BoxDecoration container;
  final TextStyle heading;

  _StyleSheet({required this.container, required this.heading});
}
