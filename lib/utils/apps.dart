
// Converted from ./mattermost-mobile/app/utils/apps.ts

import 'package:mattermost_flutter/constants/apps.dart';
import 'package:mattermost_flutter/utils/general.dart';

AppBinding cleanBinding(AppBinding binding, String topLocation) {
  return cleanBindingRec(binding, topLocation, 0);
}

AppBinding cleanBindingRec(AppBinding binding, String topLocation, int depth) {
  if (binding == null) {
    return binding;
  }

  List<int> toRemove = [];
  Map<String, bool> usedLabels = {};
  binding.bindings?.asMap().forEach((i, b) {
    // Inheritance and defaults
    b.appId ??= binding.appId;
    b.label ??= b.location ?? '';
    b.location ??= generateId();
    b.location = '${binding.location}/${b.location}';

    // Validation
    if (b.appId == null) {
      toRemove.insert(0, i);
      return;
    }

    if (b.label.trim().isEmpty) {
      toRemove.insert(0, i);
      return;
    }

    switch (topLocation) {
      case AppBindingLocations.COMMAND:
        if (RegExp(r' |	').hasMatch(b.label)) {
          toRemove.insert(0, i);
          return;
        }
        if (usedLabels[b.label] == true) {
          toRemove.insert(0, i);
          return;
        }
        break;
      case AppBindingLocations.IN_POST:
        if (usedLabels[b.label] == true) {
          toRemove.insert(0, i);
          return;
        }
        break;
    }

    // Must have only subbindings, a form, or a submit call.
    bool hasBindings = b.bindings?.isNotEmpty ?? false;
    bool hasForm = b.form != null;
    bool hasSubmit = b.submit != null;
    if ((!hasBindings && !hasForm && !hasSubmit) ||
        (hasBindings && hasForm) ||
        (hasBindings && hasSubmit) ||
        (hasForm && hasSubmit)) {
      toRemove.insert(0, i);
      return;
    }

    if (hasBindings) {
      cleanBindingRec(b, topLocation, depth + 1);

      if (b.bindings?.isEmpty ?? true) {
        toRemove.insert(0, i);
        return;
      }
    } else if (hasForm) {
      if (b.form?.submit == null && b.form?.source == null) {
        toRemove.insert(0, i);
        return;
      }
      cleanForm(b.form);
    }

    usedLabels[b.label] = true;
  });

  toRemove.forEach((i) => binding.bindings?.removeAt(i));

  return binding;
}

List<AppBinding> validateBindings(List<AppBinding>? bindings) {
  bindings ??= [];
  List<AppBinding> channelHeaderBindings = bindings.where((b) => b.location == AppBindingLocations.CHANNEL_HEADER_ICON).toList();
  List<AppBinding> postMenuBindings = bindings.where((b) => b.location == AppBindingLocations.POST_MENU_ITEM).toList();
  List<AppBinding> commandBindings = bindings.where((b) => b.location == AppBindingLocations.COMMAND).toList();

  channelHeaderBindings.forEach((b) => cleanBinding(b, AppBindingLocations.CHANNEL_HEADER_ICON));
  postMenuBindings.forEach((b) => cleanBinding(b, AppBindingLocations.POST_MENU_ITEM));
  commandBindings.forEach((b) => cleanBinding(b, AppBindingLocations.COMMAND));

  bool hasBindings(AppBinding b) => b.bindings?.isNotEmpty ?? false;
  return postMenuBindings.where(hasBindings).toList()
      ..addAll(channelHeaderBindings.where(hasBindings))
      ..addAll(commandBindings.where(hasBindings));
}

void cleanForm(AppForm? form) {
  if (form == null) {
    return;
  }

  List<int> toRemove = [];
  Map<String, bool> usedLabels = {};
  form.fields?.asMap().forEach((i, field) {
    if (field.name == null || field.name!.isEmpty) {
      toRemove.insert(0, i);
      return;
    }

    if (RegExp(r' |	').hasMatch(field.name!)) {
      toRemove.insert(0, i);
      return;
    }

    String? label = field.label;
    label ??= field.name;

    if (RegExp(r' |	').hasMatch(label)) {
      toRemove.insert(0, i);
      return;
    }

    if (usedLabels[label] == true) {
      toRemove.insert(0, i);
      return;
    }

    switch (field.type) {
      case AppFieldTypes.STATIC_SELECT:
        cleanStaticSelect(field);
        if (field.options?.isEmpty ?? true) {
          toRemove.insert(0, i);
          return;
        }
        break;
      case AppFieldTypes.DYNAMIC_SELECT:
        if (field.lookup == null) {
          toRemove.insert(0, i);
          return;
        }
        break;
      default:
        break;
    }

    usedLabels[label] = true;
  });

  toRemove.forEach((i) => form.fields?.removeAt(i));
}

void cleanStaticSelect(AppField field) {
  List<int> toRemove = [];
  Map<String, bool> usedLabels = {};
  Map<String, bool> usedValues = {};
  field.options?.asMap().forEach((i, option) {
    String? label = option.label;
    label ??= option.value;

    if (label == null || label.isEmpty) {
      toRemove.insert(0, i);
      return;
    }

    if (usedLabels[label] == true) {
      toRemove.insert(0, i);
      return;
    }

    if (usedValues[option.value] == true) {
      toRemove.insert(0, i);
      return;
    }

    usedLabels[label] = true;
    usedValues[option.value] = true;
  });

  toRemove.forEach((i) => field.options?.removeAt(i));
}

AppContext createCallContext(
    String appId, {
      String? location,
      String? channelId,
      String? teamId,
      String? postId,
      String? rootId,
    }) {
  return AppContext(
    appId: appId,
    location: location,
    channelId: channelId,
    teamId: teamId,
    postId: postId,
    rootId: rootId,
  );
}

AppCallRequest createCallRequest(
    AppCall call,
    AppContext context, {
      AppExpand defaultExpand = const AppExpand(),
      AppCallValues? values,
      String? rawCommand,
    }) {
  return AppCallRequest(
    appId: call.appId,
    context: context,
    values: values,
    expand: defaultExpand.copyWith(call.expand),
    rawCommand: rawCommand,
  );
}

AppCallResponse makeCallErrorResponse(String errMessage) {
  return AppCallResponse(
    type: AppCallResponseTypes.ERROR,
    text: errMessage,
  );
}

bool filterEmptyOptions(AppSelectOption option) {
  return option.value.isNotEmpty && !RegExp(r'^[ 	]+$').hasMatch(option.value);
}
