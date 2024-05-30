import 'package:flutter/material.dart';
import 'package:mattermost_flutter/utils/errors.dart';
import 'package:mattermost_flutter/utils/tap.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/typings/launch.dart';

class LoginForm extends StatefulWidget {
  final Map<String, dynamic> config;
  final Map<String, dynamic> license;
  final String serverDisplayName;
  final String theme;

  LoginForm({
    required this.config,
    required this.license,
    required this.serverDisplayName,
    required this.theme,
  });

  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _error;
  bool _buttonDisabled = true;
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();

    _loginController.addListener(_validateForm);
    _passwordController.addListener(_validateForm);
  }

  void _validateForm() {
    setState(() {
      _buttonDisabled = _loginController.text.isEmpty || _passwordController.text.isEmpty;
    });
  }

  Future<void> _signIn() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await login(
        widget.serverDisplayName,
        {
          'loginId': _loginController.text.toLowerCase(),
          'password': _passwordController.text,
          'config': widget.config,
          'license': widget.license,
        },
      );

      if (_checkLoginResponse(result)) {
        _goToHome(result.error);
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  bool _checkLoginResponse(dynamic data) {
    String? errorId;
    final loginError = data.error;

    if (loginError != null && loginError['server_error_id'] != null) {
      errorId = loginError['server_error_id'];
    }

    if (data.failed && MFA_EXPECTED_ERRORS.contains(errorId)) {
      _goToMfa();
      setState(() {
        _isLoading = false;
      });
      return false;
    }

    if (loginError != null && data.failed) {
      setState(() {
        _isLoading = false;
        _error = _getLoginErrorMessage(loginError);
      });
      return false;
    }

    setState(() {
      _isLoading = false;
    });

    return true;
  }

  void _goToHome(dynamic loginError) {
    final hasError = loginError != null;
    // Implement navigation to home screen
  }

  void _goToMfa() {
    // Implement navigation to MFA screen
  }

  String _getLoginErrorMessage(dynamic loginError) {
    if (loginError is Map && loginError['server_error_id'] != null) {
      final errorId = loginError['server_error_id'];
      if (errorId == 'api.user.login.invalid_credentials_email_username') {
        return 'The email and password combination is incorrect';
      }
    }

    return loginError.toString();
  }

  String _createLoginPlaceholder() {
    final loginPlaceholders = <String>[];

    if (widget.config['EnableSignInWithEmail'] == 'true') {
      loginPlaceholders.add('Email');
    }

    if (widget.config['EnableSignInWithUsername'] == 'true') {
      loginPlaceholders.add('Username');
    }

    if (widget.license['IsLicensed'] == 'true' &&
        widget.config['EnableLdap'] == 'true' &&
        widget.license['LDAP'] == 'true') {
      loginPlaceholders.add(widget.config['LdapLoginFieldName'] ?? 'AD/LDAP Username');
    }

    if (loginPlaceholders.length >= 2) {
      return loginPlaceholders.sublist(0, loginPlaceholders.length - 1).join(', ') +
          ' or ' +
          loginPlaceholders.last;
    }

    return loginPlaceholders.isNotEmpty ? loginPlaceholders.first : '';
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buttonType = _buttonDisabled ? ButtonType.disabled : ButtonType.primary;

    return Column(
      children: [
        TextField(
          controller: _loginController,
          decoration: InputDecoration(
            labelText: _createLoginPlaceholder(),
            errorText: _error,
          ),
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          onSubmitted: (_) => FocusScope.of(context).nextFocus(),
        ),
        TextField(
          controller: _passwordController,
          decoration: InputDecoration(
            labelText: 'Password',
            errorText: _error,
            suffixIcon: IconButton(
              icon: Icon(_isPasswordVisible ? Icons.visibility_off : Icons.visibility),
              onPressed: _togglePasswordVisibility,
            ),
          ),
          obscureText: !_isPasswordVisible,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _signIn(),
        ),
        if (widget.config['PasswordEnableForgotLink'] != 'false')
          TextButton(
            onPressed: () {
              // Implement forgot password functionality
            },
            child: Text('Forgot your password?'),
          ),
        ElevatedButton(
          onPressed: _buttonDisabled ? null : _signIn,
          child: _isLoading
              ? CircularProgressIndicator()
              : Text('Log In'),
        ),
      ],
    );
  }
}
