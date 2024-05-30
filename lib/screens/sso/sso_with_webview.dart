import 'dart:async';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:cookie_manager/cookie_manager.dart';

import 'package:mattermost_flutter/components/loading.dart';
import 'package:mattermost_flutter/constants/sso.dart';
import 'package:mattermost_flutter/utils/theme.dart';

class SSOWithWebView extends StatefulWidget {
  final String completeUrlPath;
  final void Function(String bearerToken, String csrfToken) doSSOLogin;
  final String loginError;
  final String loginUrl;
  final String serverUrl;
  final String ssoType;
  final ThemeData theme;

  SSOWithWebView({
    required this.completeUrlPath,
    required this.doSSOLogin,
    required this.loginError,
    required this.loginUrl,
    required this.serverUrl,
    required this.ssoType,
    required this.theme,
  });

  @override
  _SSOWithWebViewState createState() => _SSOWithWebViewState();
}

class _SSOWithWebViewState extends State<SSOWithWebView> {
  final CookieManager _cookieManager = CookieManager();
  final Set<String> _visitedUrls = Set<String>();
  final Completer<WebViewController> _controller = Completer<WebViewController>();
  bool _shouldRenderWebView = true;
  String _error = '';
  bool _messagingEnabled = false;
  Timer? _cookiesTimeout;

  @override
  void dispose() {
    _cookiesTimeout?.cancel();
    super.dispose();
  }

  void _removeCookiesFromVisited() {
    _visitedUrls.forEach((url) async {
      final cookies = await _cookieManager.loadForRequest(Uri.parse(url));
      for (var cookie in cookies) {
        await _cookieManager.deleteCookie(Uri.parse(url), cookie.name);
      }
    });
  }

  void _extractCookie(Uri parsedUrl) async {
    try {
      final original = Uri.parse(widget.serverUrl);
      parsedUrl = parsedUrl.replace(path: original.path);

      final url = '${parsedUrl.origin}${parsedUrl.path}';
      final cookies = await _cookieManager.loadForRequest(Uri.parse(url));
      final mmtoken = cookies.firstWhere((cookie) => cookie.name == 'MMAUTHTOKEN', orElse: () => null);
      final csrf = cookies.firstWhere((cookie) => cookie.name == 'MMCSRF', orElse: () => null);

      if (mmtoken != null) {
        _removeCookiesFromVisited();
        widget.doSSOLogin(mmtoken.value, csrf?.value ?? '');
        _cookiesTimeout?.cancel();
        setState(() {
          _shouldRenderWebView = false;
        });
      } else {
        _cookiesTimeout = Timer(Duration(milliseconds: 250), () => _extractCookie(parsedUrl));
      }
    } catch (e) {
      _showErrorAlert();
    }
  }

  void _showErrorAlert() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Something went wrong'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _onMessage(JavaScriptMessage message) {
    try {
      final response = jsonDecode(message.message);
      if (response['id'] != null && response['message'] != null && response['status_code'] != 200) {
        _cookiesTimeout?.cancel();
        setState(() {
          _error = response['message'];
        });
      }
    } catch (e) {
      // Do nothing
    }
  }

  void _onNavigationStateChange(String url) {
    final parsed = Uri.parse(url);
    if (!widget.serverUrl.contains(parsed.host)) {
      _visitedUrls.add(parsed.origin);
    }

    if (parsed.host.contains('.onelogin.com')) {
      // Inject JS for OneLogin form scaling
    } else if (parsed.path == widget.completeUrlPath) {
      setState(() {
        _messagingEnabled = true;
      });
    }
  }

  void _onPageFinished(String url) {
    final parsed = Uri.parse(url);
    bool isLastRedirect = url.contains(widget.completeUrlPath);
    if (widget.ssoType == Sso.SAML) {
      isLastRedirect = isLastRedirect && parsed.query == null;
    }

    if (isLastRedirect) {
      _extractCookie(parsed);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _error.isNotEmpty || widget.loginError.isNotEmpty
          ? Center(
        child: Text(_error.isNotEmpty ? _error : widget.loginError),
      )
          : _shouldRenderWebView
          ? WebView(
        initialUrl: widget.loginUrl,
        javascriptMode: JavascriptMode.unrestricted,
        onWebViewCreated: (controller) {
          _controller.complete(controller);
        },
        onPageFinished: _onPageFinished,
        navigationDelegate: (NavigationRequest request) {
          _onNavigationStateChange(request.url);
          return NavigationDecision.navigate;
        },
        onWebResourceError: (error) {
          setState(() {
            _error = error.description;
          });
        },
        javascriptChannels: _messagingEnabled
            ? {
          JavascriptChannel(
            name: 'FlutterPostMessage',
            onMessageReceived: _onMessage,
          ),
        }
            : {},
      )
          : Loading(),
    );
  }
}
