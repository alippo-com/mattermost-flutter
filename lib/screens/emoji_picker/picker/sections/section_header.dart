
import 'package:flutter/material.dart';
import 'package:mattermost_flutter/components/formatted_text.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/typography.dart';
import 'package:mattermost_flutter/context/theme.dart';

class SectionHeader extends StatelessWidget {
  final EmojiSection section;

  SectionHeader({required this.section});

  static const SECTION_HEADER_HEIGHT = 28.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final styles = _getStyleSheetFromTheme(theme);

    return Container(
      key: Key(section.id),
      height: SECTION_HEADER_HEIGHT,
      alignment: Alignment.center,
      color: theme.centerChannelBg,
      child: FormattedText(
        id: section.id,
        defaultMessage: section.icon,
        style: styles['sectionTitle'],
      ),
    );
  }

  Map<String, TextStyle> _getStyleSheetFromTheme(ThemeData theme) {
    return {
      'sectionTitle': TextStyle(
        color: changeOpacity(theme.centerChannelColor, 0.2),
        textTransform: TextTransform.uppercase,
        ...typography('Heading', 75, FontWeight.w600),
      ),
    };
  }
}
