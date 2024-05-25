// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

class ServerCredential {
  String serverUrl;
  String userId;
  String token;

  ServerCredential(
      {required this.serverUrl, required this.userId, required this.token});
}
