import 'package:flutter/material.dart';
import 'package:mattermost_flutter/types.dart';
import 'package:mattermost_flutter/components/formatted_text.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/typography.dart';

class SectionText {
  final String id;
  final String defaultMessage;
  final MessageDescriptor? values;

  SectionText({
    required this.id,
    required this.defaultMessage,
    this.values,
  });
}

class SettingBlockProps {
  final Widget? children;
  final TextStyle? containerStyles;
  final bool? disableFooter;
  final bool? disableHeader;
  final TextStyle? footerStyles;
  final SectionText? footerText;
  final TextStyle? headerStyles;
  final SectionText? headerText;
  final void Function()? onLayout;

  SettingBlockProps({
    this.children,
    this.containerStyles,
    this.disableFooter,
    this.disableHeader,
    this.footerStyles,
    this.footerText,
    this.headerStyles,
    this.headerText,
    this.onLayout,
  });
}

class SettingBlock extends StatelessWidget {
  final SettingBlockProps props;

  SettingBlock(this.props);

  @override
  Widget build(BuildContext context) {
    final theme = useTheme(context);
    final styles = getStyleSheet(theme);

    return Container(
      margin: const EdgeInsets.only(bottom: 30),
      child: GestureDetector(
        onTap: props.onLayout,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (props.headerText != null && props.disableHeader != true)
              FormattedText(
                id: props.headerText!.id,
                defaultMessage: props.headerText!.defaultMessage,
                values: props.headerText!.values,
                style: props.headerStyles ?? styles['header'],
              ),
            Container(
              margin: const EdgeInsets.only(bottom: 0),
              child: props.children,
            ),
            if (props.footerText != null && props.disableFooter != true)
              FormattedText(
                id: props.footerText!.id,
                defaultMessage: props.footerText!.defaultMessage,
                values: props.footerText!.values,
                style: props.footerStyles ?? styles['footer'],
              ),
          ],
        ),
      ),
    );
  }

  static Map<String, TextStyle> getStyleSheet(Theme theme) {
    return {
      'header': TextStyle(
        color: theme.centerChannelColor,
        fontWeight: FontWeight.w600,
        fontSize: 24,
        margin: const EdgeInsets.only(bottom: 8, left: 20, top: 12, right: 15),
      ),
      'footer': TextStyle(
        fontSize: 12,
        color: changeOpacity(theme.centerChannelColor, 0.5),
        margin: const EdgeInsets.only(top: 10, left: 15, right: 15),
      ),
    };
  }
}

class MessageDescriptor {}
