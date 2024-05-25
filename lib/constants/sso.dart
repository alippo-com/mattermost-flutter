// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

class SSOConstants {
  static const String redirectUrlScheme = 'mmauth://';
  static const String redirectUrlSchemeDev = 'mmauthbeta://';

  static const Map<String, dynamic> constants = {
    'SAML': null,
    'GITLAB': null,
    'GOOGLE': null,
    'OFFICE365': null,
    'OPENID': null,
  };
}