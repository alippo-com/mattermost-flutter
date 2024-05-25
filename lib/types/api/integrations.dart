// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

class Command {
  String id;
  String token;
  int createAt;
  int updateAt;
  int deleteAt;
  String creatorId;
  String teamId;
  String trigger;
  String method;
  String username;
  String iconUrl;
  bool autoComplete;
  String autoCompleteDesc;
  String autoCompleteHint;
  String displayName;
  String description;
  String url;
  String autoCompleteIconData;

  Command({
    required this.id,
    required this.token,
    required this.createAt,
    required this.updateAt,
    required this.deleteAt,
    required this.creatorId,
    required this.teamId,
    required this.trigger,
    required this.method,
    required this.username,
    required this.iconUrl,
    required this.autoComplete,
    required this.autoCompleteDesc,
    required this.autoCompleteHint,
    required this.displayName,
    required this.description,
    required this.url,
    this.autoCompleteIconData,
  });
}

class CommandArgs {
  String channelId;
  String teamId;
  String? rootId;
  String? parentId;

  CommandArgs({
    required this.channelId,
    required this.teamId,
    this.rootId,
    this.parentId,
  });
}

class AutocompleteSuggestion {
  String complete;
  String suggestion;
  String hint;
  String description;
  String iconData;

  AutocompleteSuggestion({
    required this.complete,
    required this.suggestion,
    required this.hint,
    required this.description,
    required this.iconData,
  });
}

class DialogSubmission {
  String url;
  String callbackId;
  String state;
  String userId;
  String channelId;
  String teamId;
  Map<String, String> submission;
  bool cancelled;

  DialogSubmission({
    required this.url,
    required this.callbackId,
    required this.state,
    required this.userId,
    required this.channelId,
    required this.teamId,
    required this.submission,
    required this.cancelled,
  });
}

class DialogOption {
  String text;
  String value;

  DialogOption({
    required this.text,
    required this.value,
  });
}

typedef SelectedDialogOption
    = DialogOption?; // Or DialogOption[]? if array is allowed

typedef SelectedDialogValue = String?; // Or String[]? if array is allowed

class DialogElement {
  String displayName;
  String name;
  String type;
  String subtype;
  dynamic defaultValue;
  String placeholder;
  String helpText;
  bool optional;
  int minLength;
  int maxLength;
  String dataSource;
  List<DialogOption> options;

  DialogElement({
    required this.displayName,
    required this.name,
    required this.type,
    required this.subtype,
    required this.defaultValue,
    required this.placeholder,
    required this.helpText,
    required this.optional,
    required this.minLength,
    required this.maxLength,
    required this.dataSource,
    required this.options,
  });
}

class InteractiveDialogConfig {
  String appId;
  String triggerId;
  String url;
  Dialog dialog;

  InteractiveDialogConfig({
    required this.appId,
    required this.triggerId,
    required this.url,
    required this.dialog,
  });
}

class Dialog {
  String callbackId;
  String title;
  String introductionText;
  String? iconUrl;
  List<DialogElement> elements;
  String submitLabel;
  bool notifyOnCancel;
  String state;

  Dialog({
    required this.callbackId,
    required this.title,
    required this.introductionText,
    this.iconUrl,
    required this.elements,
    required this.submitLabel,
    required this.notifyOnCancel,
    required this.state,
  });
}

class PostAction {
  String? id;
  String? type;
  String? name;
  bool? disabled;
  String? style;
  String? dataSource;
  List<PostActionOption>? options;
  String? defaultOption;
  PostActionIntegration? integration;
  String? cookie;

  PostAction({
    this.id,
    this.type,
    this.name,
    this.disabled,
    this.style,
    this.dataSource,
    this.options,
    this.defaultOption,
    this.integration,
    this.cookie,
  });
}

class PostActionOption {
  String text;
  String value;

  PostActionOption({
    required this.text,
    required this.value,
  });
}

class PostActionIntegration {
  String? url;
  Map<String, dynamic>? context;

  PostActionIntegration({
    this.url,
    this.context,
  });
}

class PostActionResponse {
  String status;
  String triggerId;

  PostActionResponse({
    required this.status,
    required this.triggerId,
  });
}
