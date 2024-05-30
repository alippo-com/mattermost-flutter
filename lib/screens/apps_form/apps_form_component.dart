import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:mattermost_flutter/actions/user_actions.dart';
import 'package:mattermost_flutter/components/compass_icon.dart';
import 'package:mattermost_flutter/components/markdown.dart';
import 'package:mattermost_flutter/components/button.dart';
import 'package:mattermost_flutter/context/server_context.dart';
import 'package:mattermost_flutter/context/theme_context.dart';
import 'package:mattermost_flutter/hooks/did_update.dart';
import 'package:mattermost_flutter/hooks/navigation_button_pressed.dart';
import 'package:mattermost_flutter/utils/apps.dart';
import 'package:mattermost_flutter/utils/button_styles.dart';
import 'package:mattermost_flutter/utils/helpers.dart';
import 'package:mattermost_flutter/utils/markdown.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/types/navigation.dart';
import 'package:mattermost_flutter/types/screens.dart';
import 'package:mattermost_flutter/types/app_field.dart';

class AppsFormComponent extends StatefulWidget {
  final AppForm form;
  final AvailableScreens componentId;
  final Future<DoAppCallResult<FormResponseData>> Function(AppField, AppFormValues, AppFormValue) refreshOnSelect;
  final Future<DoAppCallResult<FormResponseData>> Function(AppFormValues) submit;
  final Future<DoAppCallResult<AppLookupResponse>> Function(AppField, AppFormValues, AppFormValue) performLookupCall;

  AppsFormComponent({
    required this.form,
    required this.componentId,
    required this.refreshOnSelect,
    required this.submit,
    required this.performLookupCall,
  });

  @override
  _AppsFormComponentState createState() => _AppsFormComponentState();
}

class _AppsFormComponentState extends State<AppsFormComponent> {
  final ScrollController _scrollController = ScrollController();
  bool _submitting = false;
  String _error = '';
  Map<String, String> _errors = {};
  AppFormValues _values = {};

  @override
  void initState() {
    super.initState();
    _values = initValues(widget.form.fields);
    useDidUpdate(() {
      setState(() {
        _values = initValues(widget.form.fields);
      });
    }, [widget.form]);
  }

  void close() {
    FocusScope.of(context).unfocus();
    Navigator.of(context).pop();
  }

  Future<void> handleSubmit([String? button]) async {
    if (_submitting) return;

    final fields = widget.form.fields;
    final fieldErrors = <String, String>{};
    final elements = fieldsAsElements(fields);
    bool hasErrors = false;

    for (var element in elements) {
      final newError = checkDialogElementForError(element, element.name == widget.form.submitButtons ? button : _values[element.name]);
      if (newError != null) {
        hasErrors = true;
        fieldErrors[element.name] = newError.message;
      }
    }

    if (hasErrors) {
      setState(() {
        _errors = fieldErrors;
      });
      return;
    }

    final submission = {..._values};
    if (button != null && widget.form.submitButtons != null) {
      submission[widget.form.submitButtons] = button;
    }

    setState(() {
      _submitting = true;
    });

    final res = await widget.submit(submission);

    if (res.error != null) {
      final errorResponse = res.error!;
      final errorMessage = errorResponse.text;
      hasErrors = updateErrors(elements, errorResponse.data?.errors, errorMessage);
      if (!hasErrors) {
        close();
        return;
      }
      setState(() {
        _submitting = false;
      });
      return;
    }

    setState(() {
      _error = '';
      _errors = {};
    });

    final callResponse = res.data!;
    switch (callResponse.type) {
      case AppCallResponseTypes.OK:
        close();
        return;
      case AppCallResponseTypes.NAVIGATE:
        close();
        handleGotoLocation(context.read<ServerContext>().serverUrl, context.read<Intl>(), callResponse.navigateToUrl!);
        return;
      case AppCallResponseTypes.FORM:
        setState(() {
          _submitting = false;
        });
        return;
      default:
        updateErrors([], null, 'App response type not supported. Response type: ${callResponse.type}.');
        setState(() {
          _submitting = false;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.read<ThemeContext>().theme;
    final style = getStyleFromTheme(theme);

    return KeyboardVisibilityProvider(
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              if (_error.isNotEmpty)
                Container(
                  padding: EdgeInsets.all(16),
                  color: theme.errorBackgroundColor,
                  child: Markdown(
                    data: _error,
                    styleSheet: MarkdownStyleSheet(
                      p: TextStyle(color: theme.errorTextColor),
                    ),
                  ),
                ),
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.form.header != null)
                        Text(
                          widget.form.header!,
                          style: theme.textTheme.headline6,
                        ),
                      for (var field in widget.form.fields)
                        if (field.name != widget.form.submitButtons)
                          AppsFormField(
                            field: field,
                            value: _values[field.name],
                            onChange: (value) {
                              setState(() {
                                _values[field.name] = value;
                              });
                            },
                            error: _errors[field.name],
                            performLookup: (userInput) async {
                              final res = await widget.performLookupCall(field, _values, userInput);
                              if (res.error != null) {
                                final errorResponse = res.error!;
                                final errMsg = errorResponse.text ?? 'Unknown error.';
                                setState(() {
                                  _errors[field.name] = errMsg;
                                });
                                return [];
                              }
                              final callResp = res.data!;
                              switch (callResp.type) {
                                case AppCallResponseTypes.OK:
                                  return callResp.data?.items ?? [];
                                default:
                                  final errMsg = 'App response type not supported. Response type: ${callResp.type}.';
                                  setState(() {
                                    _errors[field.name] = errMsg;
                                  });
                                  return [];
                              }
                            },
                          ),
                      for (var option in widget.form.submitButtons?.options ?? [])
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          child: ElevatedButton(
                            onPressed: () => handleSubmit(option.value),
                            child: Text(option.label),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Map<String, dynamic> getStyleFromTheme(ThemeData theme) {
  return {
    'container': BoxDecoration(
      color: theme.scaffoldBackgroundColor,
    ),
    'errorContainer': BoxDecoration(
      margin: EdgeInsets.all(16),
      color: theme.errorColor,
    ),
    'scrollView': BoxDecoration(
      margin: EdgeInsets.symmetric(vertical: 8),
    ),
    'errorLabel': TextStyle(
      fontSize: 14,
      color: theme.errorColor,
    ),
    'buttonContainer': BoxDecoration(
      padding: EdgeInsets.all(16),
    ),
  };
}
