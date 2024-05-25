// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/services.dart';

class DialogError {
  String id;
  String defaultMessage;
  Map<String, dynamic>? values;

  DialogError({required this.id, required this.defaultMessage, this.values});
}

DialogError? checkDialogElementForError(DialogElement elem, dynamic value) {
  if (!value && !elem.optional) {
    return DialogError(
      id: 'interactive_dialog.error.required',
      defaultMessage: 'This field is required.',
    );
  }

  final type = elem.type;

  if (type == 'text' || type == 'textarea') {
    if (value != null && value.length < elem.min_length) {
      return DialogError(
        id: 'interactive_dialog.error.too_short',
        defaultMessage: 'Minimum input length is {minLength}.',
        values: {'minLength': elem.min_length},
      );
    }

    if (elem.subtype == 'email') {
      if (value != null && !value.contains('@')) {
        return DialogError(
          id: 'interactive_dialog.error.bad_email',
          defaultMessage: 'Must be a valid email address.',
        );
      }
    }

    if (elem.subtype == 'number') {
      if (value != null && value is! num) {
        return DialogError(
          id: 'interactive_dialog.error.bad_number',
          defaultMessage: 'Must be a number.',
        );
      }
    }

    if (elem.subtype == 'url') {
      if (value != null && !(value.startsWith('http://') || value.startsWith('https://'))) {
        return DialogError(
          id: 'interactive_dialog.error.bad_url',
          defaultMessage: 'URL must include http:// or https://.',
        );
      }
    }
  } else if (type == 'radio') {
    final options = elem.options;

    if (value != null && options != null && !options.any((e) => e.value == value)) {
      return DialogError(
        id: 'interactive_dialog.error.invalid_option',
        defaultMessage: 'Must be a valid option',
      );
    }
  }

  return null;
}

bool checkIfErrorsMatchElements(Map<String, dynamic> errors, List<DialogElement> elements) {
  final elemNames = elements.map((elem) => elem.name).toSet();
  return errors.keys.any((name) => elemNames.contains(name));
}

TextInputType selectKeyboardType(String? subtype) {
  switch (subtype) {
    case 'email':
      return TextInputType.emailAddress;
    case 'number':
      return TextInputType.number;
    case 'tel':
      return TextInputType.phone;
    case 'url':
      return TextInputType.url;
    default:
      return TextInputType.text;
  }
}
