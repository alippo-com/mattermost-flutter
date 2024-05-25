// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:mattermost_flutter/constants/general.dart';
import 'package:mattermost_flutter/types/base.dart';

abstract class ClientNPSMix {
  Future<Post> npsGiveFeedbackAction();
}

mixin ClientNPS<TBase extends ClientBase> on TBase implements ClientNPSMix {
  @override
  Future<Post> npsGiveFeedbackAction() async {
    return doFetch(
      '\${getPluginRoute(General.NPS_PLUGIN_ID)}/api/v1/give_feedback',
      method: 'post',
    );
  }
}
