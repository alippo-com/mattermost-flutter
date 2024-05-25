
// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

class AppManifest {
  String appId;
  String displayName;
  String? description;
  String? homepageUrl;
  
  AppManifest({required this.appId, required this.displayName, this.description, this.homepageUrl});
}

class AppModalState {
  AppForm form;
  AppCallRequest call;

  AppModalState({required this.form, required this.call});
}

class AppsState {
  List<AppBinding> bindings;
  Map<String, AppForm> bindingsForms;
  List<AppBinding> threadBindings;
  Map<String, AppForm> threadBindingsForms;
  String threadBindingsChannelId;
  bool pluginEnabled;

  AppsState({required this.bindings, required this.bindingsForms, required this.threadBindings, required this.threadBindingsForms, required this.threadBindingsChannelId, required this.pluginEnabled});
}

// The rest of the classes, like AppBinding, AppCallValues, AppContext, etc will be converted in a similar manner, replacing 'type' with 'class', ':' with ' ', '[]' with 'List<>', and '{}' with 'Map<String, dynamic>'. Also, note that all variable names are converted to camelCase.
