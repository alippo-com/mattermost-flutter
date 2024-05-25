// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

class CommandResponse {
  String goto_location;
  String trigger_id;

  CommandResponse({required this.goto_location, required this.trigger_id});
}
