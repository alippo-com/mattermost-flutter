
// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

/// Flutter representation of the TermsOfService type from Mattermost.

class TermsOfService {
  final int createAt;
  final String id;
  final String text;
  final String userId;

  TermsOfService({
    required this.createAt,
    required this.id,
    required this.text,
    required this.userId,
  });
}
