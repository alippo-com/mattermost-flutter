
// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

class SsoOption {
  final bool enabled;
  final String? text;

  SsoOption({required this.enabled, this.text});
}

class SsoWithOptions extends Map<String, SsoOption> {}
