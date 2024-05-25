import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:mattermost_flutter/actions/session.dart';
import 'package:mattermost_flutter/components/floating_text_input_label.dart';
import 'package:mattermost_flutter/components/formatted_text.dart';
import 'package:mattermost_flutter/components/loading.dart';
import 'package:mattermost_flutter/hooks/android_back_handler.dart';
import 'package:mattermost_flutter/hooks/device.dart';
import 'package:mattermost_flutter/i18n.dart';
import 'package:mattermost_flutter/screens/background.dart';
import 'package:mattermost_flutter/screens/navigation.dart';
import 'package:mattermost_flutter/utils/button_styles.dart';
import 'package:mattermost_flutter/utils/errors.dart';
import 'package:mattermost_flutter/utils/tap.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/typography.dart';

class MFA extends StatefulWidget {
    final String componentId;
    final Map<String, dynamic> config;
    final Function(dynamic) goToHome;
    final Map<String, dynamic> license;
    final String loginId;
    final String password;
    final String serverDisplayName;
    final String serverUrl;
    final Theme theme;

    const MFA({
        required this.componentId,
        required this.config,
        required this.goToHome,
        required this.license,
        required this.loginId,
        required this.password,
        required this.serverDisplayName,
        required this.serverUrl,
        required this.theme,
    });

    @override
    _MFAState createState() => _MFAState();
}

class _MFAState extends State<MFA> {
    late TextEditingController _tokenController;
    late FocusNode _focusNode;
    String _error = '';
    bool _isLoading = false;

    @override
    void initState() {
        super.initState();
        _tokenController = TextEditingController();
        _focusNode = FocusNode();
    }

    @override
    void dispose() {
        _tokenController.dispose();
        _focusNode.dispose();
        super.dispose();
    }

    void _handleInput(String userToken) {
        setState(() {
            _error = '';
        });
    }

    Future<void> _submit() async {
        FocusScope.of(context).unfocus();
        if (_tokenController.text.isEmpty) {
            setState(() {
                _error = Intl.message('Please enter an MFA token', name: 'login_mfa.tokenReq');
            });
            return;
        }

        setState(() {
            _isLoading = true;
        });

        final result = await login(widget.serverUrl, {
            'loginId': widget.loginId,
            'password': widget.password,
            'mfaToken': _tokenController.text,
            'config': widget.config,
            'license': widget.license,
            'serverDisplayName': widget.serverDisplayName,
        });

        setState(() {
            _isLoading = false;
        });

        if (result['error'] != null && result['failed']) {
            setState(() {
                _error = getErrorMessage(result['error'], context);
            });
            return;
        }

        widget.goToHome(result['error']);
    }

    @override
    Widget build(BuildContext context) {
        final theme = widget.theme;
        final styles = getStyleSheet(theme);

        return Scaffold(
            body: KeyboardVisibilityBuilder(
                builder: (context, isKeyboardVisible) {
                    return Container(
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                                colors: [theme.backgroundColor, theme.backgroundColor],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                            ),
                        ),
                        child: Center(
                            child: SingleChildScrollView(
                                child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                                    child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                            SvgPicture.asset('assets/mfa.svg', height: 56, width: 56),
                                            SizedBox(height: 20),
                                            FormattedText(
                                                id: 'login_mfa.token',
                                                defaultMessage: 'Enter MFA Token',
                                                style: styles.header,
                                            ),
                                            SizedBox(height: 12),
                                            FormattedText(
                                                id: 'login_mfa.enterToken',
                                                defaultMessage: "To complete the sign in process, please enter the code from your mobile device's authenticator app.",
                                                style: styles.subheader,
                                            ),
                                            SizedBox(height: 20),
                                            FloatingTextInput(
                                                controller: _tokenController,
                                                focusNode: _focusNode,
                                                label: Intl.message('Enter MFA Token', name: 'login_mfa.token'),
                                                error: _error.isNotEmpty ? _error : null,
                                                onChanged: _handleInput,
                                                keyboardType: TextInputType.number,
                                                textInputAction: TextInputAction.go,
                                                onSubmitted: (_) => _submit(),
                                            ),
                                            SizedBox(height: 32),
                                            ElevatedButton(
                                                onPressed: _tokenController.text.isNotEmpty ? _submit : null,
                                                child: _isLoading
                                                    ? Loading(color: theme.buttonColor)
                                                    : FormattedText(
                                                        id: 'mobile.components.select_server_view.proceed',
                                                        defaultMessage: 'Proceed',
                                                    ),
                                            ),
                                        ],
                                    ),
                                ),
                            ),
                        ),
                    );
                },
            ),
        );
    }
}

getStyleSheet(Theme theme) {
    return {
        'header': TextStyle(
            color: theme.centerChannelColor,
            fontSize: 24,
            fontWeight: FontWeight.w600,
        ),
        'subheader': TextStyle(
            color: changeOpacity(theme.centerChannelColor, 0.6),
            fontSize: 16,
        ),
    };
}