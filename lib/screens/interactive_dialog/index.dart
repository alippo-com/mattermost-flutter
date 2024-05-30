
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mattermost_flutter/i18n.dart';
import 'package:mattermost_flutter/components/compass_icon.dart';
import 'package:mattermost_flutter/components/error_text.dart';
import 'package:mattermost_flutter/screens/interactive_dialog/dialog_element.dart';
import 'package:mattermost_flutter/screens/interactive_dialog/dialog_introduction_text.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/integrations.dart';
import 'package:mattermost_flutter/context/server.dart';
import 'package:mattermost_flutter/context/theme.dart';

class InteractiveDialog extends StatefulWidget {
  final InteractiveDialogConfig config;
  final String componentId;

  InteractiveDialog({required this.config, required this.componentId});

  @override
  _InteractiveDialogState createState() => _InteractiveDialogState();
}

class _InteractiveDialogState extends State<InteractiveDialog> {
  late Map<String, dynamic> values;
  late Map<String, String> errors;
  bool submitting = false;
  String error = '';
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    values = initValues(widget.config.dialog.elements);
    errors = {};
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  Map<String, dynamic> initValues(List<DialogElement>? elements) {
    final values = <String, dynamic>{};
    elements?.forEach((e) {
      if (e.type == 'bool') {
        values[e.name] = e.default == true || e.default.toString().toLowerCase() == 'true';
      } else if (e.default != null) {
      values[e.name] = e.default;
      }
    });
    return values;
  }

  void onChange(String name, dynamic value) {
    setState(() {
      values[name] = value;
    });
  }

  void handleSubmit() async {
    final newErrors = <String, String>{};
    bool hasErrors = false;
    final elements = widget.config.dialog.elements;

    if (elements != null) {
      for (var elem in elements) {
        final newError = checkDialogElementForError(elem, values[elem.name]);
        if (newError != null) {
          newErrors[elem.name] = newError;
          hasErrors = true;
        }
      }
    }

    setState(() {
      errors = hasErrors ? newErrors : {};
    });

    if (hasErrors) {
      return;
    }

    final dialog = DialogSubmission(
      url: widget.config.url,
      callbackId: widget.config.dialog.callbackId,
      state: widget.config.dialog.state,
      submission: values,
    );

    setState(() {
      submitting = true;
    });

    final data = await submitInteractiveDialog(context.read<ServerUrl>(), dialog);

    if (data != null) {
      if (data.errors != null && data.errors.isNotEmpty && checkIfErrorsMatchElements(data.errors, elements)) {
        hasErrors = true;
        setState(() {
          errors = data.errors!;
        });
      }

      if (data.error != null) {
        hasErrors = true;
        setState(() {
          error = data.error!;
        });
        scrollController.animateTo(0.0, duration: Duration(milliseconds: 300), curve: Curves.easeOut);
      } else {
        setState(() {
          error = '';
        });
      }
    }

    if (hasErrors) {
      setState(() {
        submitting = false;
      });
    } else {
      close();
    }
  }

  void close() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().theme;
    final style = getStyleFromTheme(theme);
    final intl = IntlShape.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: close,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: submitting ? null : handleSubmit,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          controller: scrollController,
          child: Column(
            children: [
              if (error.isNotEmpty)
                ErrorText(
                  text: error,
                  textStyle: style['errorContainer'],
                ),
              if (widget.config.dialog.introductionText != null)
                DialogIntroductionText(
                  value: widget.config.dialog.introductionText!,
                ),
              if (widget.config.dialog.elements != null)
                ...widget.config.dialog.elements!.map((e) {
                  return DialogElement(
                    key: Key('dialogelement' + e.name),
                    displayName: e.displayName,
                    name: e.name,
                    type: e.type,
                    subtype: e.subtype,
                    helpText: e.helpText,
                    errorText: errors[e.name],
                    placeholder: e.placeholder,
                    maxLength: e.maxLength,
                    dataSource: e.dataSource,
                    optional: e.optional,
                    options: e.options,
                    value: values[e.name],
                    onChange: (value) => onChange(e.name, value),
                  );
                }).toList(),
            ],
          ),
        ),
      ),
    );
  }

  static Map<String, dynamic> getStyleFromTheme(ThemeData theme) {
    return {
      'container': BoxDecoration(
        color: changeOpacity(theme.primaryColor, 0.03),
      ),
      'errorContainer': TextStyle(
        marginTop: 15,
        marginLeft: 15,
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
      'scrollView': EdgeInsets.symmetric(vertical: 20),
    };
  }
}
