import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/typography.dart';
import 'package:mattermost_flutter/components/field.dart';
import 'package:mattermost_flutter/components/floating_text_input_label.dart';
import 'package:mattermost_flutter/utils/intl.dart';

class EmailField extends StatelessWidget {
  final String authService;
  final String email;
  final FloatingTextInputRef fieldRef;
  final Function(String, String) onChange;
  final Function(String) onFocusNextField;
  final bool isDisabled;
  final String label;
  final Theme theme;
  final bool isTablet;

  EmailField({
    required this.authService,
    required this.email,
    required this.fieldRef,
    required this.onChange,
    required this.onFocusNextField,
    required this.isDisabled,
    required this.label,
    required this.theme,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final intl = useIntl(context);
    final service = _services[authService];
    final style = _getStyleSheet(theme);

    String fieldDescription;
    if (service != null) {
      fieldDescription = intl.formatMessage(
        'user.edit_profile.email.auth_service',
        defaultMessage: 'Login occurs through {service}. Email cannot be updated. Email address used for notifications is {email}.',
        args: {'email': email, 'service': service},
      );
    } else {
      fieldDescription = intl.formatMessage(
        'user.edit_profile.email.web_client',
        defaultMessage: 'Email must be updated using a web client or desktop application.',
        args: {'email': email, 'service': service},
      );
    }

    final descContainer = style['container'].copyWith(paddingHorizontal: isTablet ? 42.0 : 20.0);

    return Column(
      children: [
        Field(
          blurOnSubmit: false,
          enablesReturnKeyAutomatically: true,
          fieldKey: 'email',
          fieldRef: fieldRef,
          isDisabled: isDisabled,
          keyboardType: TextInputType.emailAddress,
          label: label,
          onFocusNextField: onFocusNextField,
          onTextChange: onChange,
          returnKeyType: TextInputAction.next,
          testID: 'edit_profile_form.email',
          value: email,
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: descContainer.paddingHorizontal),
          margin: EdgeInsets.only(top: 2.0),
          child: Text(
            fieldDescription,
            style: style['text'],
            key: Key('edit_profile_form.email.input.description'),
          ),
        ),
      ],
    );
  }

  static final Map<String, String> _services = {
    'gitlab': 'GitLab',
    'google': 'Google Apps',
    'office365': 'Office 365',
    'ldap': 'AD/LDAP',
    'saml': 'SAML',
  };

  Map<String, dynamic> _getStyleSheet(Theme theme) {
    return {
      'container': Container(
        margin: EdgeInsets.only(top: 2.0),
      ),
      'text': typography('Body', 75).copyWith(
        color: changeOpacity(theme.centerChannelColor, 0.5),
      ),
    };
  }
}
