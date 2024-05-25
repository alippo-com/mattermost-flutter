
import 'package:flutter/material.dart';
import 'package:mattermost_flutter/types/database.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/queries/servers/system.dart';
import 'package:mattermost_flutter/components/formatted_text.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/i18n.dart';
import 'package:mattermost_flutter/utils/typography.dart';

class TosPrivacyContainer extends StatelessWidget {
  final ClientConfig config;
  final VoidCallback onPressTOS;
  final VoidCallback onPressPrivacyPolicy;

  TosPrivacyContainer({
    required this.config,
    required this.onPressTOS,
    required this.onPressPrivacyPolicy,
  });

  @override
  Widget build(BuildContext context) {
    final theme = useTheme(context);
    final style = _getStyleSheet(theme);

    final hasTermsOfServiceLink = config.termsOfServiceLink.isNotEmpty;
    final hasPrivacyPolicyLink = config.privacyPolicyLink.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasTermsOfServiceLink)
          FormattedText(
            id: t('mobile.tos_link'),
            defaultMessage: 'Terms of Service',
            style: style['noticeLink'],
            onPress: onPressTOS,
            key: Key('about.terms_of_service'),
          ),
        if (hasTermsOfServiceLink && hasPrivacyPolicyLink)
          Text(
            ' - ',
            style: style['footerText'].merge(style['hyphenText']),
          ),
        if (hasPrivacyPolicyLink)
          FormattedText(
            id: t('mobile.privacy_link'),
            defaultMessage: 'Privacy Policy',
            style: style['noticeLink'],
            onPress: onPressPrivacyPolicy,
            key: Key('about.privacy_policy'),
          ),
      ],
    );
  }

  Map<String, TextStyle> _getStyleSheet(ThemeData theme) {
    return {
      'noticeLink': typography('Body', 50).copyWith(color: theme.linkColor),
      'footerText': typography('Body', 50).copyWith(
        color: changeOpacity(theme.centerChannelColor, 0.5),
        marginBottom: 10.0,
      ),
      'hyphenText': TextStyle(
        marginBottom: 0.0,
      ),
    };
  }
}
