  void handleConnect([String? manualUrl]) async {
    if (buttonDisabled && manualUrl == null) {
      return;
    }

    if (connecting && cancelPing != null) {
      cancelPing!();
      return;
    }

    final serverUrl = manualUrl ?? url;
    if (serverUrl.trim().isEmpty) {
      setState(() {
        urlError = 'Please enter a valid server URL';
      });
      return;
    }

    if (!isServerUrlValid(serverUrl)) {
      return;
    }

    if (displayNameError != null) {
      setState(() {
        displayNameError = null;
      });
    }

    if (urlError != null) {
      setState(() {
        urlError = null;
      });
    }

    final server = await getServerByDisplayName(displayName);
    final credentials = await getServerCredentials(serverUrl);
    if (server != null && server.lastActiveAt > 0 && credentials?.token != null) {
      setState(() {
        buttonDisabled = true;
        displayNameError = 'You are using this name for another server.';
        connecting = false;
      });
      return;
    }

    pingServer(serverUrl);
  }

  bool isServerUrlValid(String serverUrl) {
    final testUrl = sanitizeUrl(serverUrl);
    if (!isValidUrl(testUrl)) {
      setState(() {
        urlError = 'URL must start with http:// or https://';
      });
      return false;
    }
    return true;
  }

  void pingServer(String pingUrl, [bool retryWithHttp = true]) async {
    bool canceled = false;
    setState(() {
      connecting = true;
    });
    cancelPing = () {
      canceled = true;
      setState(() {
        connecting = false;
        cancelPing = null;
      });
    };

    final ping = await getServerUrlAfterRedirect(pingUrl, !retryWithHttp);
    if (ping.url == null) {
      cancelPing!();
      if (retryWithHttp) {
        final nurl = pingUrl.replace('https:', 'http:');
        pingServer(nurl, false);
      } else {
        setState(() {
          urlError = getErrorMessage(ping.error, context);
          buttonDisabled = true;
          connecting = false;
        });
      }
      return;
    }
    final result = await doPing(ping.url, true, managedConfig?.timeout != null ? int.parse(managedConfig!.timeout!) : null);

    if (canceled) {
      return;
    }

    if (result.error != null) {
      setState(() {
        urlError = getErrorMessage(result.error, context);
        buttonDisabled = true;
        connecting = false;
      });
      return;
    }

    canReceiveNotifications(ping.url, result.canReceiveNotifications as String, context);
    final data = await fetchConfigAndLicense(ping.url, true);
    if (data.error != null) {
      setState(() {
        buttonDisabled = true;
        urlError = getErrorMessage(data.error, context);
        connecting = false;
      });
      return;
    }

    if (data.config?.diagnosticId == null) {
      setState(() {
        urlError = 'A DiagnosticId value is missing for this server. Contact your system admin to review this value and restart the server.';
        connecting = false;
      });
      return;
    }

    final server = await getServerByIdentifier(data.config!.diagnosticId);
    final credentials = await getServerCredentials(ping.url);
    setState(() {
      connecting = false;
    });

    if (server != null && server.lastActiveAt > 0 && credentials?.token != null) {
      setState(() {
        buttonDisabled = true;
        urlError = 'You are already connected to this server.';
      });
      return;
    }

    displayLogin(ping.url, data.config!, data.license!);
  }

  void displayLogin(String serverUrl, ClientConfig config, ClientLicense license) {
    final enabledSSOs = loginOptions(config, license).enabledSSOs;
    final hasLoginForm = loginOptions(config, license).hasLoginForm;
    final numberSSOs = loginOptions(config, license).numberSSOs;
    final ssoOptions = loginOptions(config, license).ssoOptions;

    final passProps = {
      'config': config,
      'extra': widget.extra,
      'hasLoginForm': hasLoginForm,
      'launchError': widget.launchError,
      'launchType': widget.launchType,
      'license': license,
      'serverDisplayName': displayName,
      'serverUrl': serverUrl,
      'ssoOptions': ssoOptions,
      'theme': widget.theme,
    };

    final redirectSSO = !hasLoginForm && numberSSOs == 1;
    final screen = redirectSSO ? Screens.sso : Screens.login;
    if (redirectSSO) {
      passProps['ssoType'] = enabledSSOs[0];
    }

    goToScreen(screen, '', passProps, loginAnimationOptions());
    setState(() {
      connecting = false;
      buttonDisabled = false;
      url = serverUrl;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = useTheme(context);
    return Scaffold(
      body: Background(
        theme: theme,
        child: SafeArea(
          child: Column(
            children: [
              ServerHeader(
                additionalServer: widget.launchType == Launch.addServerFromDeepLink || widget.launchType == Launch.addServer,
                theme: theme,
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: _keyboardAwareRef,
                  child: ServerForm(
                    autoFocus: widget.launchType == Launch.addServerFromDeepLink || widget.launchType == Launch.addServer,
                    buttonDisabled: buttonDisabled,
                    connecting: connecting,
                    displayName: displayName,
                    displayNameError: displayNameError,
                    disableServerUrl: managedConfig?.allowOtherServers == 'false',
                    handleConnect: handleConnect,
                    handleDisplayNameTextChanged: (text) {
                      setState(() {
                        displayName = text;
                        displayNameError = null;
                      });
                    },
                    handleUrlTextChanged: (text) {
                      setState(() {
                        urlError = null;
                        url = text;
                      });
                    },
                    isModal: widget.isModal,
                    theme: theme,
                    url: url,
                    urlError: urlError,
                  ),
                ),
              ),
              AppVersion(),
            ],
          ),
        ),
      ),
    );
  }
}
