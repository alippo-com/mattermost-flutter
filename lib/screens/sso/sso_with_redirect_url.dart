
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mattermost_flutter/components/formatted_text.dart';
import 'package:mattermost_flutter/constants/sso.dart';
import 'package:mattermost_flutter/managers/network_manager.dart';
import 'package:mattermost_flutter/utils/button_styles.dart';
import 'package:mattermost_flutter/utils/errors.dart';
import 'package:mattermost_flutter/utils/general.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/url.dart';
import 'package:mattermost_flutter/types/theme.dart';
import 'package:url_launcher/url_launcher.dart';

class SSOWithRedirectURL extends HookWidget {
  final Function(String, String) doSSOLogin;
  final String loginError;
  final String loginUrl;
  final String serverUrl;
  final Function(String) setLoginError;
  final ThemeData theme;

  SSOWithRedirectURL({
    required this.doSSOLogin,
    required this.loginError,
    required this.loginUrl,
    required this.serverUrl,
    required this.setLoginError,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final style = getStyleSheet(theme);
    final intl = useIntl();
    String customUrlScheme = Sso.REDIRECT_URL_SCHEME;
    if (isBetaApp()) {
      customUrlScheme = Sso.REDIRECT_URL_SCHEME_DEV;
    }

    final redirectUrl = '$customUrlScheme://callback';
    final error = useState<String>('');

    void init([bool resetErrors = true]) {
      if (resetErrors) {
        error.value = '';
        setLoginError('');
        NetworkManager.invalidateClient(serverUrl);
        NetworkManager.createClient(serverUrl);
      }
      final parsedUrl = urlParse(loginUrl);
      final query = Map<String, String>.from(parsedUrl.query ?? {})
        ..['redirect_to'] = redirectUrl;
      parsedUrl.set('query', qs.stringify(query));
      final url = parsedUrl.toString();

      void onError(dynamic e) {
        String message;
        if (e != null &&
            Platform.isAndroid &&
            isErrorWithMessage(e) &&
            e.message.contains(RegExp(r'no activity found to handle intent', caseSensitive: false))) {
          message = intl.formatMessage(
            id: 'mobile.oauth.failed_to_open_link_no_browser',
            defaultMessage: 'The link failed to open. Please verify that a browser is installed on the device.',
          );
        } else {
          message = intl.formatMessage(
            id: 'mobile.oauth.failed_to_open_link',
            defaultMessage: 'The link failed to open. Please try again.',
          );
        }
        error.value = message;
      }

      tryOpenURL(url, onError);
    }

    useEffect(() {
      void onURLChange(String url) {
        if (url.startsWith(redirectUrl)) {
          final parsedUrl = urlParse(url);
          final bearerToken = parsedUrl.query['MMAUTHTOKEN'];
          final csrfToken = parsedUrl.query['MMCSRF'];
          if (bearerToken != null && csrfToken != null) {
            doSSOLogin(bearerToken, csrfToken);
          } else {
            error.value = intl.formatMessage(
              id: 'mobile.oauth.failed_to_login',
              defaultMessage: 'Your login attempt failed. Please try again.',
            );
          }
        }
      }

      final listener = Linking.addEventListener('url', onURLChange);

      final timeout = setTimeout(() {
        init(false);
      }, 1000);

      return () {
        listener.remove();
        clearTimeout(timeout);
      };
    }, []);

    return Scaffold(
      body: Center(
        child: error.value.isNotEmpty || loginError.isNotEmpty
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FormattedText(
                    id: 'mobile.oauth.switch_to_browser.error_title',
                    defaultMessage: 'Sign in error',
                    style: style['infoTitle'],
                  ),
                  Text('${loginError.isNotEmpty ? loginError : error.value}.', style: style['errorText']),
                  ElevatedButton(
                    onPressed: () => init(),
                    style: ElevatedButton.styleFrom(
                      primary: theme.primaryColor,
                      padding: EdgeInsets.all(16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: FormattedText(
                      id: 'mobile.oauth.try_again',
                      defaultMessage: 'Try again',
                      style: style['buttonText'],
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FormattedText(
                    id: 'mobile.oauth.switch_to_browser.title',
                    defaultMessage: 'Redirecting...',
                    style: style['infoTitle'],
                  ),
                  FormattedText(
                    id: 'mobile.oauth.switch_to_browser',
                    defaultMessage: 'You are being redirected to your login provider',
                    style: style['infoText'],
                  ),
                ],
              ),
      ),
    );
  }

  static Map<String, TextStyle> getStyleSheet(ThemeData theme) {
    return {
      'button': TextStyle(
        marginTop: 25,
      ),
      'container': TextStyle(
        flex: 1,
        paddingHorizontal: 24,
      ),
      'errorText': TextStyle(
        color: changeOpacity(theme.colorScheme.onSurface, 0.72),
        textAlign: TextAlign.center,
        ...typography('Body', 200, FontWeight.w400),
      ),
      'infoContainer': TextStyle(
        alignItems: CrossAxisAlignment.center,
        flex: 1,
        justifyContent: MainAxisAlignment.center,
      ),
      'infoText': TextStyle(
        color: changeOpacity(theme.colorScheme.onSurface, 0.72),
        ...typography('Body', 100, FontWeight.w400),
      ),
      'infoTitle': TextStyle(
        color: theme.colorScheme.onSurface,
        marginBottom: 4,
        ...typography('Headline', 700),
      ),
    };
  }
}
