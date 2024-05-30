
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mattermost_flutter/components/compass_icon.dart';
import 'package:mattermost_flutter/components/selected_chip.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class FloatingTextChipsInput extends HookWidget {
  final TextEditingController textController;
  final List<String> chipsValues;
  final Function(String) onChipRemove;
  final Function(String) onTextInputChange;
  final Function() onTextInputSubmitted;
  final String label;
  final String? error;
  final bool editable;
  final bool isKeyboardInput;
  final bool showErrorIcon;
  final String? errorIcon;
  final String? placeholder;
  final TextStyle? textInputStyle;
  final TextStyle? labelTextStyle;
  final TextStyle? errorTextStyle;
  final TextStyle? chipTextStyle;
  final TextStyle? chipContainerStyle;
  final TextStyle? containerStyle;
  final Function()? onFocus;
  final Function()? onBlur;
  final Function()? onPress;
  final Function()? onLayout;

  FloatingTextChipsInput({
    required this.textController,
    required this.chipsValues,
    required this.onChipRemove,
    required this.onTextInputChange,
    required this.onTextInputSubmitted,
    required this.label,
    this.error,
    this.editable = true,
    this.isKeyboardInput = true,
    this.showErrorIcon = true,
    this.errorIcon,
    this.placeholder,
    this.textInputStyle,
    this.labelTextStyle,
    this.errorTextStyle,
    this.chipTextStyle,
    this.chipContainerStyle,
    this.containerStyle,
    this.onFocus,
    this.onBlur,
    this.onPress,
    this.onLayout,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final focused = useState(false);
    final focusedLabel = useState<bool?>(null);
    final hasValues = textController.text.isNotEmpty || chipsValues.isNotEmpty;
    final shouldShowError = !focused.value && error != null;

    final textInputContainerStyles = [
      textStyle,
      !editable ? readOnlyStyle : null,
      BoxDecoration(
        border: Border.all(
          width: focusedLabel.value ?? false ? 2 : 1,
          color: focused.value
              ? theme.buttonColor
              : shouldShowError
              ? theme.errorColor
              : changeOpacity(theme.centerChannelColor, 0.16),
        ),
      ),
      textInputStyle,
    ];

    void handlePressOnContainer() {
      if (!focused.value) {
        FocusScope.of(context).requestFocus(FocusNode());
      }
    }

    return GestureDetector(
      onTap: onPress,
      onPanUpdate: onLayout,
      child: Container(
        width: double.infinity,
        decoration: containerStyle,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: handlePressOnContainer,
              child: AnimatedDefaultTextStyle(
                style: TextStyle(
                  fontSize: placeholder != null || hasValues ? 12 : 16,
                  color: shouldShowError
                      ? theme.errorColor
                      : focused.value
                      ? theme.buttonColor
                      : changeOpacity(theme.centerChannelColor, 0.64),
                ),
                duration: Duration(milliseconds: 100),
                child: Text(
                  label,
                  style: labelTextStyle,
                ),
              ),
            ),
            Container(
              decoration: textInputContainerStyles,
              child: Wrap(
                spacing: 6,
                children: [
                  ...chipsValues.map(
                        (chipValue) => SelectedChip(
                      key: ValueKey(chipValue),
                      id: chipValue,
                      text: chipValue,
                      onRemove: onChipRemove,
                      chipTextStyle: chipTextStyle,
                      chipContainerStyle: chipContainerStyle,
                    ),
                  ),
                  TextField(
                    controller: textController,
                    focusNode: FocusNode(
                      onFocusChange: (isFocused) {
                        focused.value = isFocused;
                        focusedLabel.value = hasValues;
                        if (isFocused && onFocus != null) onFocus!();
                        if (!isFocused && onBlur != null) onBlur!();
                      },
                    ),
                    enabled: isKeyboardInput && editable,
                    onChanged: onTextInputChange,
                    onSubmitted: (_) => onTextInputSubmitted(),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: placeholder,
                    ),
                    style: textInputStyle,
                  ),
                ],
              ),
            ),
            if (shouldShowError)
              Row(
                children: [
                  if (showErrorIcon && errorIcon != null)
                    Icon(
                      Icons.error_outline,
                      color: theme.errorColor,
                    ),
                  Text(
                    error ?? '',
                    style: errorTextStyle,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
