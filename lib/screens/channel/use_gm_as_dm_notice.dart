
// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:mattermost_flutter/actions/remote/preference.dart';
import 'package:mattermost_flutter/constants.dart';
import 'package:mattermost_flutter/context/server.dart';
import 'package:mattermost_flutter/helpers/api/preference.dart';
import 'package:mattermost_flutter/store/ephemeral_store.dart';
import 'package:mattermost_flutter/types/database/models/servers/preference.dart';

void useGMasDMNotice(BuildContext context, String userId, String channelType, List<PreferenceModel> dismissedGMasDMNotice, bool hasGMasDMFeature) {
  final intl = useIntl();
  final serverUrl = useServerUrl();

  useEffect(() {
    if (!hasGMasDMFeature) {
      return;
    }

    final preferenceValue = getPreferenceAsBool(dismissedGMasDMNotice, Preferences.CATEGORIES.SYSTEM_NOTICE, Preferences.NOTICES.GM_AS_DM);
    if (preferenceValue) {
      return;
    }

    if (channelType != 'G') {
      return;
    }

    if (EphemeralStore.noticeShown.contains(Preferences.NOTICES.GM_AS_DM)) {
      return;
    }

    void onRemindMeLaterPress() {
      EphemeralStore.noticeShown.add(Preferences.NOTICES.GM_AS_DM);
    }

    void onHideAndForget() {
      EphemeralStore.noticeShown.add(Preferences.NOTICES.GM_AS_DM);
      savePreference(serverUrl, [
        PreferenceModel(
          category: Preferences.CATEGORIES.SYSTEM_NOTICE,
          name: Preferences.NOTICES.GM_AS_DM,
          value: 'true',
          userId: userId,
        ),
      ]);
    }

    // Show the GM as DM notice if needed
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(intl.formatMessage({'id': 'system_notice.title.gm_as_dm', 'defaultMessage': 'Updates to Group Messages'})),
          content: Text(intl.formatMessage({'id': 'system_notice.body.gm_as_dm', 'defaultMessage': 'You will now be notified for all activity in your group messages along with a notification badge for every new message.

You can configure this in notification preferences for each group message.'})),
          actions: <Widget>[
            TextButton(
              child: Text(intl.formatMessage({'id': 'system_notice.remind_me', 'defaultMessage': 'Remind Me Later'})),
              onPressed: () {
                onRemindMeLaterPress();
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(intl.formatMessage({'id': 'system_notice.dont_show', 'defaultMessage': "Don't Show Again"})),
              onPressed: () {
                onHideAndForget();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }, []);
}
