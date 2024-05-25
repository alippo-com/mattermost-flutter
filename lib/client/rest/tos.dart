// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:mattermost_flutter/types/base.dart';

abstract class ClientTosMix {
  Future<Map<String, dynamic>> updateMyTermsOfServiceStatus(String termsOfServiceId, bool accepted);
  Future<TermsOfService> getTermsOfService();
}

mixin ClientTos on ClientBase implements ClientTosMix {
  @override
  Future<Map<String, dynamic>> updateMyTermsOfServiceStatus(String termsOfServiceId, bool accepted) async {
    return doFetch(
      "${getUserRoute('me')}/terms_of_service",
      'POST',
      body: {'termsOfServiceId': termsOfServiceId, 'accepted': accepted},
    );
  }

  @override
  Future<TermsOfService> getTermsOfService() async {
    return doFetch(
      "${urlVersion}/terms_of_service",
      'GET',
    );
  }
}
