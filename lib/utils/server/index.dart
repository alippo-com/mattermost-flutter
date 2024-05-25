Map<String, dynamic> loginOptions(ClientConfig config, ClientLicense license) {
  final isLicensed = license.isLicensed == 'true';
  final samlEnabled = config.enableSaml == 'true' && isLicensed && license.saml == 'true';
  final gitlabEnabled = config.enableSignUpWithGitLab == 'true';
  final isMinServerVersionForCloudOAuthChanges = isMinimumServerVersion(config.version, 7, 6);
  var googleEnabled = false;
  var o365Enabled = false;
  var openIdEnabled = false;
  if (isMinServerVersionForCloudOAuthChanges) {
    googleEnabled = config.enableSignUpWithGoogle == 'true';
    o365Enabled = config.enableSignUpWithOffice365 == 'true';
    openIdEnabled = config.enableSignUpWithOpenId == 'true';
  } else {
    googleEnabled = config.enableSignUpWithGoogle == 'true' && isLicensed;
    o365Enabled = config.enableSignUpWithOffice365 == 'true' && isLicensed && license.office365OAuth == 'true';
    openIdEnabled = config.enableSignUpWithOpenId == 'true' && isLicensed;
  }
  final ldapEnabled = isLicensed && config.enableLdap == 'true' && license.ldap == 'true';
  final hasLoginForm = config.enableSignInWithEmail == 'true' || config.enableSignInWithUsername == 'true' || ldapEnabled;
  final ssoOptions = {
    Sso.SAML: {'enabled': samlEnabled, 'text': config.samlLoginButtonText},
    Sso.GITLAB: {'enabled': gitlabEnabled},
    Sso.GOOGLE: {'enabled': googleEnabled},
    Sso.OFFICE365: {'enabled': o365Enabled},
    Sso.OPENID: {'enabled': openIdEnabled, 'text': config.openIdButtonText},
  };
  final enabledSSOs = ssoOptions.keys.where((key) => ssoOptions[key]['enabled']).toList();
  final numberSSOs = enabledSSOs.length;

  return {
    'enabledSSOs': enabledSSOs,
    'hasLoginForm': hasLoginForm,
    'numberSSOs': numberSSOs,
    'ssoOptions': ssoOptions,
  };
}

Future<void> loginToServer(Theme theme, String serverUrl, String displayName, ClientConfig config, ClientLicense license) async {
  await dismissBottomSheet();
  final closeButtonId = 'close-server';
  final loginOptionsResult = loginOptions(config, license);
  final props = {
    'closeButtonId': closeButtonId,
    'config': config,
    'hasLoginForm': loginOptionsResult['hasLoginForm'],
    'launchType': Launch.AddServer,
    'license': license,
    'serverDisplayName': displayName,
    'serverUrl': serverUrl,
    'ssoOptions': loginOptionsResult['ssoOptions'],
    'theme': theme,
  };

  final redirectSSO = !loginOptionsResult['hasLoginForm'] && loginOptionsResult['numberSSOs'] == 1;
  final screen = redirectSSO ? Screens.SSO : Screens.LOGIN;
  if (redirectSSO) {
    props['ssoType'] = loginOptionsResult['enabledSSOs'][0];
  }

  final options = buildServerModalOptions(theme, closeButtonId);

  showModal(screen, '', props, options);
}

Future<void> editServer(Theme theme, ServersModel server) async {
  final closeButtonId = 'close-server-edit';
  final props = {
    'closeButtonId': closeButtonId,
    'server': server,
    'theme': theme,
  };
  final options = buildServerModalOptions(theme, closeButtonId);

  showModal(Screens.EDIT_SERVER, '', props, options);
}

Future<void> alertServerLogout(String displayName, VoidCallback onPress, Intl intl) async {
  AlertDialog alert = AlertDialog(
    title: Text(intl.formatMessage({
      'id': 'server.logout.alert_title',
      'defaultMessage': 'Are you sure you want to log out of {displayName}?',
    }, [displayName])),
    content: Text(intl.formatMessage({
      'id': 'server.logout.alert_description',
      'defaultMessage': 'All associated data will be removed',
    })),
    actions: [
      TextButton(
        child: Text(intl.formatMessage({'id': 'mobile.post.cancel', 'defaultMessage': 'Cancel'})),
        onPressed: () {},
      ),
      TextButton(
        child: Text(intl.formatMessage({'id': 'servers.logout', 'defaultMessage': 'Log out'})),
        onPressed: onPress,
      ),
    ],
  );

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

Future<void> alertServerRemove(String displayName, VoidCallback onPress, Intl intl) async {
  AlertDialog alert = AlertDialog(
    title: Text(intl.formatMessage({
      'id': 'server.remove.alert_title',
      'defaultMessage': 'Are you sure you want to remove {displayName}?',
    }, [displayName])),
    content: Text(intl.formatMessage({
      'id': 'server.remove.alert_description',
      'defaultMessage': 'This will remove it from your list of servers. All associated data will be removed',
    })),
    actions: [
      TextButton(
        child: Text(intl.formatMessage({'id': 'mobile.post.cancel', 'defaultMessage': 'Cancel'})),
        onPressed: () {},
      ),
      TextButton(
        child: Text(intl.formatMessage({'id': 'servers.remove', 'defaultMessage': 'Remove'})),
        onPressed: onPress,
      ),
    ],
  );

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

Future<void> alertServerError(Intl intl, dynamic error) async {
  final message = getErrorMessage(error, intl);
  AlertDialog alert = AlertDialog(
    title: Text(intl.formatMessage({
      'id': 'server.websocket.unreachable',
      'defaultMessage': 'Server is unreachable.',
    })),
    content: Text(message),
    actions: [
      TextButton(
        child: Text('OK'),
        onPressed: () {},
      ),
    ],
  );

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

Future<void> alertServerAlreadyConnected(Intl intl) async {
  AlertDialog alert = AlertDialog(
    content: Text(intl.formatMessage({
      'id': 'mobile.server_identifier.exists',
      'defaultMessage': 'You are already connected to this server.',
    })),
    actions: [
      TextButton(
        child: Text('OK'),
        onPressed: () {},
      ),
    ],
  );

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

List<ServersModel> sortServersByDisplayName(List<ServersModel> servers, Intl intl) {
  String serverName(ServersModel s) {
    if (s.displayName == s.url) {
      return intl.formatMessage({'id': 'servers.default', 'defaultMessage': 'Default Server'});
    }
    return s.displayName;
  }

  servers.sort((a, b) => serverName(a).compareTo(serverName(b)));
  return servers;
}

void unsupportedServerAdminAlert(String serverDisplayName, Intl intl, [VoidCallback? onPress]) {
  final title = intl.formatMessage({'id': 'mobile.server_upgrade.title', 'defaultMessage': 'Server upgrade required'});

  final message = intl.formatMessage({
    'id': 'server_upgrade.alert_description',
    'defaultMessage': 'Your server, {serverDisplayName}, is running an unsupported server version. Users will be exposed to compatibility issues that cause crashes or severe bugs breaking core functionality of the app. Upgrading to server version {supportedServerVersion} or later is required.',
  }, [serverDisplayName, SupportedServer.FULL_VERSION]);

  AlertDialog alert = AlertDialog(
    title: Text(title),
    content: Text(message),
    actions: [
      TextButton(
        child: Text(intl.formatMessage({'id': 'server_upgrade.dismiss', 'defaultMessage': 'Dismiss'})),
        onPressed: onPress,
      ),
      TextButton(
        child: Text(intl.formatMessage({'id': 'server_upgrade.learn_more', 'defaultMessage': 'Learn More'})),
        onPressed: () {
          final url = 'https://docs.mattermost.com/administration/release-lifecycle.html';
          final onError = () {
            AlertDialog errorAlert = AlertDialog(
              title: Text(intl.formatMessage({'id': 'mobile.link.error.title', 'defaultMessage': 'Error'})),
              content: Text(intl.formatMessage({'id': 'mobile.link.error.text', 'defaultMessage': 'Unable to open the link.'})),
              actions: [
                TextButton(
                  child: Text('OK'),
                  onPressed: () {},
                ),
              ],
            );
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return errorAlert;
              },
            );
          };

          tryOpenURL(url, onError);
        },
      ),
    ],
  );

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

void unsupportedServerAlert(String serverDisplayName, Intl intl, [VoidCallback? onPress]) {
  final title = intl.formatMessage({'id': 'unsupported_server.title', 'defaultMessage': 'Unsupported server version'});

  final message = intl.formatMessage({
    'id': 'unsupported_server.message',
    'defaultMessage': 'Your server, {serverDisplayName}, is running an unsupported server version. You may experience compatibility issues that cause crashes or severe bugs breaking core functionality of the app. Please contact your System Administrator to upgrade your Mattermost server.',
  }, [serverDisplayName]);

  AlertDialog alert = AlertDialog(
    title: Text(title),
    content: Text(message),
    actions: [
      TextButton(
        child: Text('OK'),
        onPressed: onPress,
      ),
    ],
  );

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

Map<String, dynamic> buildServerModalOptions(Theme theme, String closeButtonId) {
  final closeButton = Icons.close;
  final closeButtonTestId = closeButtonId.replaceAll('close-', 'close.').replaceAll('-', '_') + '.button';
  return {
    'layout': {
      'backgroundColor': theme.centerChannelBg,
      'componentBackgroundColor': theme.centerChannelBg,
    },
    'topBar': {
      'visible': true,
      'drawBehind': true,
      'translucient': true,
      'noBorder': true,
      'elevation': 0,
      'background': {'color': Colors.transparent},
      'leftButtons': [
        {
          'id': closeButtonId,
          'icon': closeButton,
          'testID': closeButtonTestId,
        },
      ],
      'leftButtonColor': null,
      'title': {'color': theme.sidebarHeaderTextColor},
      'scrollEdgeAppearance': {
        'active': true,
        'noBorder': true,
        'translucid': true,
      },
    },
  };
}
