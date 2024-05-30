import 'package:flutter/material.dart';
import 'package:mattermost_flutter/components/autocomplete_selector.dart';
import 'package:mattermost_flutter/components/bool_setting.dart';
import 'package:mattermost_flutter/components/radio_setting.dart';
import 'package:mattermost_flutter/components/text_setting.dart';
import 'package:mattermost_flutter/types/interactive_dialog_element_type.dart';
import 'package:mattermost_flutter/types/interactive_dialog_text_subtype.dart';
import 'package:mattermost_flutter/types/post_action_option.dart';

const int TEXT_DEFAULT_MAX_LENGTH = 150;
const int TEXTAREA_DEFAULT_MAX_LENGTH = 3000;

KeyboardType selectKeyboardType(String type, [String? subtype]) {
  if (type == 'textarea') {
    return TextInputType.multiline;
  }
  return selectKB(subtype);
}

class DialogElement extends StatelessWidget {
  final String displayName;
  final String name;
  final String type;
  final String? subtype;
  final String? placeholder;
  final String? helpText;
  final String? errorText;
  final int? maxLength;
  final String? dataSource;
  final bool optional;
  final List<PostActionOption>? options;
  final dynamic value;
  final Function(String, dynamic) onChange;

  DialogElement({
    required this.displayName,
    required this.name,
    required this.type,
    this.subtype,
    this.placeholder,
    this.helpText,
    this.errorText,
    this.maxLength,
    this.dataSource,
    this.optional = false,
    this.options,
    required this.value,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case 'text':
      case 'textarea':
        return TextSetting(
          label: displayName,
          maxLength: maxLength ?? (type == 'text' ? TEXT_DEFAULT_MAX_LENGTH : TEXTAREA_DEFAULT_MAX_LENGTH),
          value: value as String,
          placeholder: placeholder,
          helpText: helpText,
          errorText: errorText,
          onChange: (newValue) => _handleChange(newValue),
          optional: optional,
          multiline: type == 'textarea',
          keyboardType: selectKeyboardType(type, subtype),
          secureTextEntry: subtype == 'password',
          disabled: false,
        );
      case 'select':
        return AutocompleteSelector(
          label: displayName,
          dataSource: dataSource,
          options: options,
          optional: optional,
          onSelected: (newValue) => _handleSelect(newValue),
          helpText: helpText,
          errorText: errorText,
          placeholder: placeholder,
          showRequiredAsterisk: true,
          selected: value as String,
          roundedBorders: false,
        );
      case 'radio':
        return RadioSetting(
          label: displayName,
          helpText: helpText,
          errorText: errorText,
          options: options,
          onChange: (newValue) => _handleChange(newValue),
          value: value as String,
        );
      case 'bool':
        return BoolSetting(
          label: displayName,
          value: value as bool,
          placeholder: placeholder,
          helpText: helpText,
          errorText: errorText,
          optional: optional,
          onChange: (newValue) => _handleChange(newValue),
        );
      default:
        return SizedBox();
    }
  }

  void _handleChange(dynamic newValue) {
    if (type == 'text' && subtype == 'number') {
      onChange(name, int.parse(newValue as String));
      return;
    }
    onChange(name, newValue);
  }

  void _handleSelect(dynamic newValue) {
    if (newValue == null) {
      onChange(name, '');
      return;
    }
    onChange(name, newValue.value);
  }
}
