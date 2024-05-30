
import 'package:flutter/material.dart';
import 'package:mattermost_flutter/types/database.dart';
import 'package:mattermost_flutter/components/formatted_text.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/i18n.dart';
import 'package:mattermost_flutter/utils/typography.dart';

class Title extends StatelessWidget {
  final ClientConfig config;
  final ClientLicense license;

  Title({required this.config, required this.license});

  @override
  Widget build(BuildContext context) {
    final theme = useTheme(context);
    final style = _getStyleSheet(theme);

    String id = t('about.teamEditiont0');
    String defaultMessage = 'Team Edition';

    if (config.buildEnterpriseReady == 'true') {
      id = t('about.teamEditiont1');
      defaultMessage = 'Enterprise Edition';

      if (license.isLicensed == 'true') {
        id = t('about.enterpriseEditione1');
        defaultMessage = 'Enterprise Edition';
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 36.0),
          child: Text(
            '${config.siteName} ',
            style: style.title.copyWith(marginTop: 8.0),
            key: Key('about.site_name'),
          ),
        ),
        FormattedText(
          id: id,
          defaultMessage: defaultMessage,
          style: style.title.copyWith(marginBottom: 8.0),
          key: Key('about.title'),
        ),
      ],
    );
  }

  _getStyleSheet(ThemeData theme) {
    return {
      'title': typography('Heading', 800, 'SemiBold').copyWith(color: theme.centerChannelColor),
      'spacerTop': EdgeInsets.only(top: 8.0),
      'spacerBottom': EdgeInsets.only(bottom: 8.0),
    };
  }
}
