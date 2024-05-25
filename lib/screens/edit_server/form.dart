import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:mattermost_flutter/components/custom_floating_text_input.dart';
import 'package:mattermost_flutter/components/custom_formatted_text.dart';
import 'package:mattermost_flutter/components/loading.dart';
import 'package:mattermost_flutter/hooks/device.dart';
import 'package:mattermost_flutter/i18n.dart';
import 'package:mattermost_flutter/utils/button_styles.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/url.dart';
import 'package:mattermost_flutter/types/keyboard_aware_scroll_view.dart';
import 'package:mattermost_flutter/types/theme.dart';

class EditServerForm extends StatefulWidget {
  final bool buttonDisabled;
  final bool connecting;
  final String? displayName;
  final String? displayNameError;
  final VoidCallback handleUpdate;
  final ValueChanged<String> handleDisplayNameTextChanged;
  final GlobalKey<KeyboardAwareScrollViewState> keyboardAwareRef;
  final String serverUrl;
  final Theme theme;

  const EditServerForm({
    Key? key,
    required this.buttonDisabled,
    required this.connecting,
    this.displayName,
    this.displayNameError,
    required this.handleUpdate,
    required this.handleDisplayNameTextChanged,
    required this.keyboardAwareRef,
    required this.serverUrl,
    required this.theme,
  }) : super(key: key);

  @override
  _EditServerFormState createState() => _EditServerFormState();
}

class _EditServerFormState extends State<EditServerForm> {
  late TextEditingController _displayNameController;
  late FocusNode _displayNameFocusNode;
  late Theme _theme;
  late bool _isTablet;
  late Size _dimensions;

  @override
  void initState() {
    super.initState();
    _displayNameController = TextEditingController(text: widget.displayName);
    _displayNameFocusNode = FocusNode();
    _theme = widget.theme;
    _isTablet = useIsTablet(context);
    _dimensions = MediaQuery.of(context).size;
  }

  void _onBlur() {
    if (Platform.isIOS) {
      final reset = !_displayNameFocusNode.hasFocus;
      if (reset) {
        widget.keyboardAwareRef.currentState?.scrollToPosition(0, 0);
      }
    }
  }

  void _onUpdate() {
    FocusScope.of(context).unfocus();
    widget.handleUpdate();
  }

  void _onFocus() {
    if (Platform.isIOS) {
      int offsetY = 160;
      if (_isTablet) {
        final bool isLandscape = _dimensions.width > _dimensions.height;
        offsetY = isLandscape ? 230 : 100;
      }
      WidgetsBinding.instance?.addPostFrameCallback((_) {
        widget.keyboardAwareRef.currentState?.scrollToPosition(0, offsetY);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final styles = _getStyleSheet(_theme);
    final buttonType = widget.buttonDisabled ? 'disabled' : 'default';
    final styleButtonText = buttonTextStyle(_theme, 'lg', 'primary', buttonType);
    final styleButtonBackground = buttonBackgroundStyle(_theme, 'lg', 'primary', buttonType);

    String buttonID = t('edit_server.save');
    String buttonText = 'Save';
    Widget? buttonIcon;

    if (widget.connecting) {
      buttonID = t('edit_server.saving');
      buttonText = 'Saving';
      buttonIcon = Loading(
        containerStyle: styles['loadingContainerStyle'],
        color: _theme.buttonColor,
      );
    }

    final String saveButtonTestId = widget.buttonDisabled
        ? 'edit_server_form.save.button.disabled'
        : 'edit_server_form.save.button';

    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 20),
          alignment: Alignment.center,
          constraints: BoxConstraints(maxWidth: 600),
          child: Column(
            children: [
              TextField(
                controller: _displayNameController,
                focusNode: _displayNameFocusNode,
                autocorrect: false,
                textCapitalization: TextCapitalization.none,
                decoration: InputDecoration(
                  labelText: I18n.of(context).trans('mobile.components.select_server_view.displayName'),
                  errorText: widget.displayNameError,
                ),
                onChanged: widget.handleDisplayNameTextChanged,
                onSubmitted: (_) => _onUpdate(),
                onEditingComplete: _onBlur,
              ),
              if (widget.displayNameError == null)
                CustomFormattedText(
                  defaultMessage: 'Server: ${removeProtocol(stripTrailingSlashes(widget.serverUrl))}',
                  id: 'edit_server.display_help',
                  style: styles['chooseText'],
                  testID: 'edit_server_form.display_help',
                ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: styleButtonBackground,
                  padding: EdgeInsets.all(15),
                ),
                onPressed: widget.buttonDisabled ? null : _onUpdate,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (buttonIcon != null) buttonIcon!,
                    Text(
                      buttonText,
                      style: styleButtonText,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Map<String, TextStyle> _getStyleSheet(Theme theme) {
    return {
      'chooseText': TextStyle(
        color: changeOpacity(_theme.centerChannelColor, 0.64),
        marginTop: 8,
        ...typography('Body', 75, 'Regular'),
      ),
      'loadingContainerStyle': TextStyle(
        marginRight: 10,
        padding: 0,
        top: -2,
      ),
    };
  }
}
