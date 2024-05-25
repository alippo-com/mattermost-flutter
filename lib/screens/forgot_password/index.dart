
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';
import 'package:mattermost_flutter/actions/remote/user.dart';
import 'package:mattermost_flutter/components/formatted_text.dart';
import 'package:mattermost_flutter/components/floating_text_input_label.dart';
import 'package:mattermost_flutter/constants/general.dart';
import 'package:mattermost_flutter/context/server.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/hooks/use_safe_area.dart';
import 'package:mattermost_flutter/hooks/use_intl.dart';
import 'package:mattermost_flutter/hooks/use_is_tablet.dart';
import 'package:mattermost_flutter/screens/navigation.dart';
import 'package:mattermost_flutter/utils/helpers.dart';
import 'package:mattermost_flutter/utils/tap.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/typography.dart';
import 'package:mattermost_flutter/types/user_model.dart';

class ForgotPassword extends HookWidget {
  final String componentId;
  final String serverUrl;
  final ThemeData theme;

  ForgotPassword({
    required this.componentId,
    required this.serverUrl,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final dimensions = MediaQuery.of(context).size;
    final isTablet = useIsTablet();
    final email = useState<String>('');
    final error = useState<String>('');
    final isPasswordLinkSent = useState<bool>(false);
    final intl = useIntl();
    final keyboardAwareRef = useState<ScrollController>(ScrollController());
    final styles = getStyleSheet(theme);

    void changeEmail(String emailAddress) {
      email.value = emailAddress;
      error.value = '';
    }

    void onFocus() {
      if (Theme.of(context).platform == TargetPlatform.iOS) {
        double offsetY = 150;
        if (isTablet) {
          final width = dimensions.width;
          final height = dimensions.height;
          final isLandscape = width > height;
          offsetY = isLandscape ? 230 : 150;
        }
        Future.delayed(Duration.zero, () {
          keyboardAwareRef.value.animateTo(
            offsetY,
            duration: Duration(milliseconds: 200),
            curve: Curves.easeInOut,
          );
        });
      }
    }

    void onReturn() {
      Navigator.pop(context);
    }

    Future<void> submitResetPassword() async {
      FocusScope.of(context).unfocus();
      if (!isEmail(email.value)) {
        error.value = intl.formatMessage({
          'id': 'password_send.error',
          'defaultMessage': 'Please enter a valid email address.',
        });
        return;
      }

      final response = await sendPasswordResetEmail(serverUrl, email.value);
      if (response.status == 'OK') {
        isPasswordLinkSent.value = true;
        return;
      }

      error.value = intl.formatMessage({
        'id': 'password_send.generic_error',
        'defaultMessage': 'We were unable to send you a reset password link. Please contact your System Admin for assistance.',
      });
    }

    Widget getCenterContent() {
      if (isPasswordLinkSent.value) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inbox, size: 100),
              FormattedText(
                style: styles['successTitle'],
                id: 'password_send.link.title',
                defaultMessage: 'Reset Link Sent',
              ),
              FormattedText(
                style: styles['successText'],
                id: 'password_send.link',
                defaultMessage: 'If the account exists, a password reset email will be sent to:',
              ),
              Text(email.value, style: styles['successText']),
              ElevatedButton(
                onPressed: onReturn,
                child: FormattedText(
                  id: 'password_send.return',
                  defaultMessage: 'Return to Log In',
                ),
              ),
            ],
          ),
        );
      }

      return SingleChildScrollView(
        controller: keyboardAwareRef.value,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FormattedText(
              style: styles['header'],
              id: 'password_send.reset',
              defaultMessage: 'Reset Your Password',
            ),
            FormattedText(
              style: styles['subheader'],
              id: 'password_send.description',
              defaultMessage: 'To reset your password, enter the email address you used to sign up',
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  FloatingTextInputLabel(
                    label: intl.formatMessage({'id': 'login.email', 'defaultMessage': 'Email'}),
                    onChanged: changeEmail,
                    onFocus: onFocus,
                    onSubmit: submitResetPassword,
                    errorText: error.value,
                  ),
                  ElevatedButton(
                    onPressed: email.value.isNotEmpty ? submitResetPassword : null,
                    child: FormattedText(
                      id: 'password_send.reset',
                      defaultMessage: 'Reset my password',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: FormattedText(
          id: 'password_send.reset',
          defaultMessage: 'Reset Your Password',
        ),
      ),
      body: getCenterContent(),
    );
  }

  Map<String, TextStyle> getStyleSheet(ThemeData theme) {
    return {
      'header': TextStyle(
        color: theme.primaryColor,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      'subheader': TextStyle(
        color: theme.primaryColor.withOpacity(0.6),
        fontSize: 16,
      ),
      'successTitle': TextStyle(
        color: theme.primaryColor,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      'successText': TextStyle(
        color: theme.primaryColor.withOpacity(0.6),
        fontSize: 16,
        textAlign: TextAlign.center,
      ),
    };
  }
}
  