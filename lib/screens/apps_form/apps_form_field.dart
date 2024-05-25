import 'package:flutter/material.dart';
import 'package:mattermost_flutter/components/autocomplete_selector.dart';
import 'package:mattermost_flutter/components/markdown.dart';
import 'package:mattermost_flutter/components/settings/bool_setting.dart';
import 'package:mattermost_flutter/components/settings/text_setting.dart';
import 'package:mattermost_flutter/constants/views.dart' as ViewConstants;
import 'package:mattermost_flutter/constants/apps.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/utils/integrations.dart';
import 'package:mattermost_flutter/utils/markdown.dart';
import 'package:mattermost_flutter/utils/theme.dart';

const int TEXT_DEFAULT_MAX_LENGTH = 150;
const int TEXTAREA_DEFAULT_MAX_LENGTH = 3000;

class AppsFormField extends StatelessWidget {
  final AppField field;
  final String name;
  final String? errorText;
  final AppFormValue value;
  final Function(String, AppFormValue) onChange;
  final Future<List<AppSelectOption>> Function(String, String) performLookup;

  AppsFormField({
    required this.field,
    required this.name,
    this.errorText,
    required this.value,
    required this.onChange,
    required this.performLookup,
  });

  AppSelectOption dialogOptionToAppSelectOption(DialogOption option) {
    return AppSelectOption(label: option.text, value: option.value);
  }

  DialogOption appSelectOptionToDialogOption(AppSelectOption option) {
    return DialogOption(text: option.label, value: option.value);
  }

  Map<String, dynamic> getStyleSheet(ThemeData theme) {
    return {
      'markdownFieldContainer': {
        'marginTop': 15.0,
        'marginBottom': 10.0,
        'marginLeft': 15.0,
      },
      'markdownFieldText': {
        'fontSize': 14.0,
        'color': theme.centerChannelColor,
      },
    };
  }

  String selectDataSource(String fieldType) {
    switch (fieldType) {
      case AppFieldTypes.USER:
        return ViewConstants.DATA_SOURCE_USERS;
      case AppFieldTypes.CHANNEL:
        return ViewConstants.DATA_SOURCE_CHANNELS;
      case AppFieldTypes.DYNAMIC_SELECT:
        return ViewConstants.DATA_SOURCE_DYNAMIC;
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = getStyleSheet(theme);
    final testID = 'AppFormElement.$name';
    final placeholder = field.hint ?? '';
    final displayName = field.modalLabel ?? field.label ?? '';

    void handleChange(dynamic newValue) {
      onChange(name, newValue);
    }

    Future<List<DialogOption>> getDynamicOptions(String userInput) async {
      final options = await performLookup(field.name, userInput);
      return options.map(appSelectOptionToDialogOption).toList();
    }

    List<DialogOption>? options;
    if (field.type == AppFieldTypes.STATIC_SELECT) {
      options = field.options?.map(appSelectOptionToDialogOption).toList();
    } else if (field.type == AppFieldTypes.DYNAMIC_SELECT) {
      if (value != null) {
        if (value is List) {
          options = (value as List).map(appSelectOptionToDialogOption).toList();
        } else {
          options = [appSelectOptionToDialogOption(value as AppSelectOption)];
        }
      }
    }

    dynamic selectedValue;
    if (SelectableAppFieldTypes.contains(field.type)) {
      if (value != null) {
        if (value is List) {
          selectedValue = (value as List).map((v) => v.value).toList();
        } else {
          selectedValue = value as String;
        }
      }
    }

    switch (field.type) {
      case AppFieldTypes.TEXT:
        return TextSetting(
          label: displayName,
          maxLength: field.maxLength ?? (field.subtype == 'textarea' ? TEXTAREA_DEFAULT_MAX_LENGTH : TEXT_DEFAULT_MAX_LENGTH),
          value: value as String,
          placeholder: placeholder,
          helpText: field.description,
          errorText: errorText,
          onChange: handleChange,
          optional: !field.isRequired,
          multiline: field.subtype == 'textarea',
          keyboardType: selectKeyboardType(field.subtype),
          secureTextEntry: field.subtype == 'password',
          disabled: field.readonly,
          testID: testID,
        );
      case AppFieldTypes.USER:
      case AppFieldTypes.CHANNEL:
      case AppFieldTypes.STATIC_SELECT:
      case AppFieldTypes.DYNAMIC_SELECT:
        return AutocompleteSelector(
          label: displayName,
          dataSource: selectDataSource(field.type),
          options: options,
          optional: !field.isRequired,
          onSelected: handleChange,
          getDynamicOptions: field.type == AppFieldTypes.DYNAMIC_SELECT ? getDynamicOptions : null,
          helpText: field.description,
          errorText: errorText,
          placeholder: placeholder,
          showRequiredAsterisk: true,
          selected: selectedValue,
          roundedBorders: false,
          disabled: field.readonly,
          isMultiselect: field.multiselect,
          testID: testID,
        );
      case AppFieldTypes.BOOL:
        return BoolSetting(
          label: displayName,
          value: value as bool,
          placeholder: placeholder,
          helpText: field.description,
          errorText: errorText,
          optional: !field.isRequired,
          onChange: handleChange,
          disabled: field.readonly,
          testID: testID,
        );
      case AppFieldTypes.MARKDOWN:
        if (field.description == null) return Container();
        return Container(
          margin: EdgeInsets.only(
            top: style['markdownFieldContainer']['marginTop'],
            bottom: style['markdownFieldContainer']['marginBottom'],
            left: style['markdownFieldContainer']['marginLeft'],
          ),
          child: Markdown(
            value: field.description!,
            mentionKeys: [],
            disableAtMentions: true,
            location: '',
            blockStyles: getMarkdownBlockStyles(theme),
            textStyles: getMarkdownTextStyles(theme),
            baseTextStyle: TextStyle(
              fontSize: style['markdownFieldText']['fontSize'],
              color: style['markdownFieldText']['color'],
            ),
            theme: theme,
          ),
        );
      default:
        return Container();
    }
  }
}
