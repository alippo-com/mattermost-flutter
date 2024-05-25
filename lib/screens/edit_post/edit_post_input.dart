
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:mattermost_flutter/constants/typography.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/utils/general.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/types/managed_config.dart';
import 'package:provider/provider.dart';

class EditPostInput extends HookWidget {
  final double inputHeight;
  final String message;
  final bool hasError;
  final Function(int) onTextSelectionChange;
  final Function(String) onChangeText;

  const EditPostInput({
    Key? key,
    required this.inputHeight,
    required this.message,
    required this.hasError,
    required this.onTextSelectionChange,
    required this.onChangeText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = useTheme(context);
    final styles = _getStyleSheet(theme);
    final managedConfig = Provider.of<ManagedConfig>(context);
    final disableCopyAndPaste = managedConfig.copyAndPasteProtection == 'true';

    final inputRef = useTextEditingController();
    final inputStyle = useMemo(() => [
      styles.input,
      {'height': inputHeight},
    ], [inputHeight, styles]);

    final containerStyle = useMemo(() => [
      styles.inputContainer,
      if (hasError) {'marginTop': 0},
      {'height': inputHeight},
    ], [styles, inputHeight]);

    return Container(
      style: containerStyle,
      child: TextField(
        controller: inputRef,
        style: inputStyle,
        decoration: InputDecoration(
          hintText: 'Edit the post...',
          hintStyle: TextStyle(
            color: theme.centerChannelColor.withOpacity(0.5),
          ),
        ),
        onChanged: onChangeText,
        onSelectionChanged: (selection, cause) {
          onTextSelectionChange(selection.end);
        },
        keyboardAppearance: getKeyboardAppearanceFromTheme(theme),
        maxLines: null,
        enableInteractiveSelection: !disableCopyAndPaste,
        smartDashesType: SmartDashesType.disabled,
        inputFormatters: [
          FilteringTextInputFormatter.deny(RegExp(r'
'), replacementString: ' '),
        ],
      ),
    );
  }

  TextStyle _getTextStyle(BuildContext context) {
    final theme = useTheme(context);
    return TextStyle(
      color: theme.centerChannelColor,
      padding: EdgeInsets.all(15),
      textAlignVertical: TextAlignVertical.top,
      ...typography('Body', 200),
    );
  }

  BoxDecoration _getStyleSheet(Theme theme) {
    return BoxDecoration(
      color: theme.centerChannelBg,
      marginTop: 2,
    );
  }
}

class EditPostInputRef {
  final TextEditingController controller;
  EditPostInputRef(this.controller);

  void focus() {
    controller?.focus();
  }
}
