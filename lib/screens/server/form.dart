import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:mattermost_flutter/components/floating_text_input.dart';
import 'package:mattermost_flutter/components/formatted_text.dart';
import 'package:mattermost_flutter/components/loading.dart';
import 'package:mattermost_flutter/i18n.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/types/screens/theme.dart';
import 'package:reactive_forms/reactive_forms.dart'; // Assuming a package for form management
import 'package:intl/intl.dart';

class ServerForm extends StatefulWidget {
  final bool autoFocus;
  final bool buttonDisabled;
  final bool connecting;
  final String displayName;
  final String? displayNameError;
  final bool disableServerUrl;
  final VoidCallback handleConnect;
  final ValueChanged<String> handleDisplayNameTextChanged;
  final ValueChanged<String> handleUrlTextChanged;
  final bool isModal;
  final GlobalKey<FormState> keyboardAwareKey;
  final Theme theme;
  final String url;
  final String? urlError;

  ServerForm({
    this.autoFocus = false,
    required this.buttonDisabled,
    required this.connecting,
    this.displayName = '',
    this.displayNameError,
    required this.disableServerUrl,
    required this.handleConnect,
    required this.handleDisplayNameTextChanged,
    required this.handleUrlTextChanged,
    this.isModal = false,
    required this.keyboardAwareKey,
    required this.theme,
    this.url = '',
    this.urlError,
  });

  @override
  _ServerFormState createState() => _ServerFormState();
}

class _ServerFormState extends State<ServerForm> {
  late TextEditingController displayNameController;
  late TextEditingController urlController;

  @override
  void initState() {
    super.initState();
    displayNameController = TextEditingController(text: widget.displayName);
    urlController = TextEditingController(text: widget.url);
  }

  @override
  void dispose() {
    displayNameController.dispose();
    urlController.dispose();
    super.dispose();
  }

  void focus() {
    if (Platform.isIOS) {
      double offsetY = widget.isModal ? 120.0 : 160.0;
      if (useIsTablet()) {
        final dimensions = MediaQuery.of(context).size;
        final isLandscape = dimensions.width > dimensions.height;
        offsetY = isLandscape ? 230.0 : 100.0;
      }
      Future.microtask(() {
        widget.keyboardAwareKey.currentState?.scrollTo(offsetY);
      });
    }
  }

  void onBlur() {
    if (Platform.isIOS) {
      final reset = !urlController.text.isNotEmpty && !displayNameController.text.isNotEmpty;
      if (reset) {
        widget.keyboardAwareKey.currentState?.scrollTo(0.0);
      }
    }
  }

  void onConnect() {
    FocusScope.of(context).unfocus();
    widget.handleConnect();
  }

  void onFocus() {
    focus();
  }

  void onUrlSubmit() {
    displayNameController.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final styles = getStyleSheet(widget.theme);

    final buttonType = widget.buttonDisabled ? 'disabled' : 'default';
    final styleButtonText = buttonTextStyle(widget.theme, 'lg', 'primary', buttonType);
    final styleButtonBackground = buttonBackgroundStyle(widget.theme, 'lg', 'primary', buttonType);

    String buttonText = 'Connect';
    Widget? buttonIcon;

    if (widget.connecting) {
      buttonText = 'Connecting';
      buttonIcon = Loading(
        containerStyle: styles.loadingContainerStyle,
        color: widget.theme.buttonColor,
      );
    }

    final connectButtonTestId = widget.buttonDisabled ? 'server_form.connect.button.disabled' : 'server_form.connect.button';

    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: 20.0),
      constraints: BoxConstraints(maxWidth: 600),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FloatingTextInput(
            autoCorrect: false,
            autoCapitalize: TextCapitalization.none,
            autofocus: widget.autoFocus,
            blurOnSubmit: false,
            containerStyle: styles.enterServer,
            enablesReturnKeyAutomatically: true,
            editable: !widget.disableServerUrl,
            error: widget.urlError,
            keyboardType: TextInputType.url,
            label: Intl.message('Enter Server URL', name: 'enterServerUrl'),
            onBlur: (_) => onBlur(),
            onChanged: widget.handleUrlTextChanged,
            onFocus: onFocus,
            onSubmitEditing: (_) => onUrlSubmit(),
            controller: urlController,
            returnKeyType: TextInputAction.next,
            spellCheck: false,
            testID: 'server_form.server_url.input',
            theme: widget.theme,
          ),
          FloatingTextInput(
            autoCorrect: false,
            autoCapitalize: TextCapitalization.none,
            enablesReturnKeyAutomatically: true,
            error: widget.displayNameError,
            label: Intl.message('Display Name', name: 'displayName'),
            onBlur: (_) => onBlur(),
            onChanged: widget.handleDisplayNameTextChanged,
            onFocus: onFocus,
            onSubmitEditing: (_) => onConnect(),
            controller: displayNameController,
            returnKeyType: TextInputAction.done,
            spellCheck: false,
            testID: 'server_form.server_display_name.input',
            theme: widget.theme,
          ),
          if (widget.displayNameError == null)
            FormattedText(
              defaultMessage: 'Choose a display name for your server',
              id: 'mobile.components.select_server_view.displayHelp',
              style: styles.chooseText,
              testID: 'server_form.display_help',
            ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: styleButtonBackground,
              padding: EdgeInsets.all(15.0),
              minimumSize: Size(double.infinity, 50),
              textStyle: styleButtonText,
            ),
            onPressed: widget.buttonDisabled ? null : onConnect,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (buttonIcon != null) buttonIcon,
                Text(buttonText),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Styles conversion
  Map<String, TextStyle> getStyleSheet(Theme theme) {
    return {
      'formContainer': TextStyle(
        color: changeOpacity(theme.centerChannelColor, 0.64),
        padding: EdgeInsets.symmetric(horizontal: 20),
      ),
      'enterServer': TextStyle(
        marginBottom: 24,
      ),
      'fullWidth': TextStyle(
        width: double.infinity,
      ),
      'chooseText': TextStyle(
        alignSelf: Alignment.centerLeft,
        color: changeOpacity(theme.centerChannelColor, 0.64),
        marginTop: 8,
        ...typography('Body', 75, 'Regular'),
      ),
      'connectButton': TextStyle(
        backgroundColor: changeOpacity(theme.centerChannelColor, 0.08),
        width: double.infinity,
        marginTop: 32,
        marginHorizontal: 20,
        padding: 15,
      ),
      'connectingIndicator': TextStyle(
        marginRight: 10,
      ),
      'loadingContainerStyle': TextStyle(
        marginRight: 10,
        padding: 0,
        top: -2,
      ),
    };
  }
}
