import 'package:flutter/material.dart';
import 'package:mattermost_flutter/components/floating_text_input_label.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/hooks/device.dart';
import 'package:mattermost_flutter/utils/theme.dart';

class Field extends StatelessWidget {
  final bool? isDisabled;
  final String fieldKey;
  final String label;
  final int? maxLength;
  final Function(String, String) onTextChange;
  final bool isOptional;
  final String testID;
  final String? error;
  final String value;
  final TextEditingController fieldController;
  final FocusNode fieldFocusNode;
  final Function(String) onFocusNextField;
  final TextInputType keyboardType;
  final TextCapitalization autoCapitalize;
  final bool autoCorrect;

  Field({
    Key? key,
    this.isDisabled = false,
    this.isOptional = false,
    required this.fieldKey,
    required this.label,
    required this.onTextChange,
    required this.testID,
    required this.value,
    required this.fieldController,
    required this.fieldFocusNode,
    required this.onFocusNextField,
    this.maxLength,
    this.error,
    this.keyboardType = TextInputType.text,
    this.autoCapitalize = TextCapitalization.none,
    this.autoCorrect = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = useTheme(context);
    final isTablet = useIsTablet(context);

    final onChangeText = (String text) => onTextChange(fieldKey, text);

    final onSubmitEditing = () => onFocusNextField(fieldKey);

    final style = getStyleSheet(theme);

    final keyboard = (Theme.of(context).platform == TargetPlatform.android && keyboardType == TextInputType.url)
        ? TextInputType.text
        : keyboardType;

    final optionalText = ' (optional)'; // Replace with intl equivalent as needed

    final formattedLabel = isOptional ? '$label$optionalText' : label;

    final textInputStyle = isDisabled! ? style['disabledStyle'] : null;
    final subContainer = [
      style['viewContainer'],
      EdgeInsets.symmetric(horizontal: isTablet ? 42.0 : 20.0)
    ];
    final fieldInputTestId = isDisabled! ? '$testID.input.disabled' : '$testID.input';

    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          FloatingTextInput(
            autoCapitalize: autoCapitalize,
            autoCorrect: autoCorrect,
            disableFullscreenUI: true,
            enabled: !isDisabled!,
            keyboardAppearance: getKeyboardAppearanceFromTheme(theme),
            keyboardType: keyboard,
            label: formattedLabel,
            maxLength: maxLength,
            onChanged: onChangeText,
            testID: fieldInputTestId,
            theme: theme,
            error: error,
            controller: fieldController,
            focusNode: fieldFocusNode,
            onFieldSubmitted: (_) => onSubmitEditing(),
            style: textInputStyle,
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> getStyleSheet(ThemeData theme) {
    return {
      'viewContainer': BoxDecoration(
        margin: EdgeInsets.symmetric(vertical: 8.0),
        alignment: Alignment.center,
        width: double.infinity,
      ),
      'disabledStyle': BoxDecoration(
        color: changeOpacity(theme.primaryColor, 0.04),
      ),
    };
  }
}
