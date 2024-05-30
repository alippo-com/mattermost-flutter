import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:mattermost_flutter/actions/session.dart';
import 'package:mattermost_flutter/constants.dart';
import 'package:mattermost_flutter/hooks/android_back_handler.dart';
import 'package:mattermost_flutter/hooks/navigation_button_pressed.dart';
import 'package:mattermost_flutter/managers/network_manager.dart';
import 'package:mattermost_flutter/screens/background.dart';
import 'package:mattermost_flutter/screens/navigation.dart';
import 'package:mattermost_flutter/utils/errors.dart';
import 'package:mattermost_flutter/utils/log.dart';
import 'package:mattermost_flutter/types/launch.dart';
import 'package:mattermost_flutter/types/screens/navigation.dart';
import 'package:mattermost_flutter/types/theme.dart';
import 'package:flutter_safe_area/flutter_safe_area.dart';
import 'sso_with_redirect_url.dart';
import 'sso_with_webview.dart';

class SSO extends StatefulWidget {
  final String? closeButtonId;
  final AvailableScreens componentId;
  final Map<String, dynamic> config;
  final String ssoType;
  final String serverDisplayName;
  final Theme theme;

  SSO({
    this.closeButtonId,
    required this.componentId,
    required this.config,
    required this.ssoType,
    required this.serverDisplayName,
    required this.theme,
  });

  @override
  _SSOState createState() => _SSOState();
}

class _SSOState extends State<SSO> {
  late double translateX;
  String loginError = '';

  @override
  void initState() {
    super.initState();
    translateX = MediaQuery.of(context).size.width;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        translateX = 0;
      });
    });
  }

  void onLoadEndError(dynamic e) {
    logWarning('Failed to set store from local data', e);
    setState(() {
      loginError = getFullErrorMessage(e);
    });
  }

  Future<void> doSSOLogin(String bearerToken, String csrfToken) async {
    final result = await ssoLogin(widget.config['serverUrl'], widget.serverDisplayName, widget.config['DiagnosticId'], bearerToken, csrfToken);
    if (result.error && result.failed) {
      onLoadEndError(result.error);
      return;
    }
    goToHome(result.error);
  }

  void goToHome([dynamic error]) {
    final hasError = widget.launchError || error != null;
    resetToHome(widget.componentId, extra, widget.launchError, widget.launchType, widget.serverUrl);
  }

  void dismiss() {
    if (widget.config['serverUrl'] != null) {
      NetworkManager.invalidateClient(widget.config['serverUrl']);
    }
    dismissModal(widget.componentId);
  }

  @override
  Widget build(BuildContext context) {
    String completeUrlPath;
    String loginUrl;

    switch (widget.ssoType) {
      case Sso.GOOGLE:
        completeUrlPath = '/signup/google/complete';
        loginUrl = '${widget.config['serverUrl']}/oauth/google/mobile_login';
        break;
      case Sso.GITLAB:
        completeUrlPath = '/signup/gitlab/complete';
        loginUrl = '${widget.config['serverUrl']}/oauth/gitlab/mobile_login';
        break;
      case Sso.SAML:
        completeUrlPath = '/login/sso/saml';
        loginUrl = '${widget.config['serverUrl']}/login/sso/saml?action=mobile';
        break;
      case Sso.OFFICE365:
        completeUrlPath = '/signup/office365/complete';
        loginUrl = '${widget.config['serverUrl']}/oauth/office365/mobile_login';
        break;
      case Sso.OPENID:
        completeUrlPath = '/signup/openid/complete';
        loginUrl = '${widget.config['serverUrl']}/oauth/openid/mobile_login';
        break;
      default:
        completeUrlPath = '';
        loginUrl = '';
        break;
    }

    final props = {
      'doSSOLogin': doSSOLogin,
      'loginError': loginError,
      'loginUrl': loginUrl,
      'setLoginError': (String error) {
        setState(() {
          loginError = error;
        });
      },
      'theme': widget.theme,
    };

    final ssoComponent = widget.config['inAppSessionAuth'] == 'true'
        ? SSOWithWebView(
      completeUrlPath: completeUrlPath,
      serverUrl: widget.config['serverUrl'],
      ssoType: widget.ssoType,
    )
        : SSOWithRedirectURL(
      serverUrl: widget.config['serverUrl'],
    );

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Background(theme: widget.theme),
            AnimatedContainer(
              duration: Duration(milliseconds: 350),
              transform: Matrix4.translationValues(translateX, 0, 0),
              child: ssoComponent,
            ),
          ],
        ),
      ),
    );
  }
}