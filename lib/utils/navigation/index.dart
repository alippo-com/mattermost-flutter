// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:mattermost_flutter/constants.dart';
import 'package:mattermost_flutter/utils/errors.dart';
import 'package:mattermost_flutter/types/screens/navigation.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

Set<AvailableScreens> appearanceControlledScreens = {
  Screens.ONBOARDING,
  Screens.SERVER,
  Screens.LOGIN,
  Screens.FORGOT_PASSWORD,
  Screens.MFA,
  Screens.SSO,
  Screens.REVIEW_APP,
  Screens.SHARE_FEEDBACK,
};

void mergeNavigationOptions(String componentId, Map<String, dynamic> options) {
  // Flutter does not have a direct equivalent to Navigation.mergeOptions
  // This needs to be handled according to the specific navigation package used
  // For example, using flutter's Navigator:
  // Navigator.of(context).pushNamed(componentId, arguments: options);
}

void alertTeamRemove(String displayName, AppLocalizations intl) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(intl.alert_removed_from_team_title),
        content: Text(intl.alert_removed_from_team_description(displayName)),
        actions: [
          TextButton(
            child: Text(intl.mobile_oauth_something_wrong_okButton),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

void alertChannelRemove(String displayName, AppLocalizations intl) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(intl.alert_removed_from_channel_title),
        content: Text(intl.alert_removed_from_channel_description(displayName)),
        actions: [
          TextButton(
            child: Text(intl.mobile_oauth_something_wrong_okButton),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

void alertChannelArchived(String displayName, AppLocalizations intl) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(intl.alert_channel_deleted_title),
        content: Text(intl.alert_channel_deleted_description(displayName)),
        actions: [
          TextButton(
            child: Text(intl.mobile_oauth_something_wrong_okButton),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

void alertTeamAddError(dynamic error, AppLocalizations intl) {
  String errMsg = intl.join_team_error_message;

  if (isServerError(error)) {
    if (error.serverErrorId == ServerErrors.TEAM_MEMBERSHIP_DENIAL_ERROR_ID) {
      errMsg = intl.join_team_error_group_error;
    } else if (isErrorWithMessage(error) && error.message != null) {
      errMsg = error.message!;
    }
  }

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(intl.join_team_error_title),
        content: Text(errMsg),
        actions: [
          TextButton(
            child: Text(intl.mobile_oauth_something_wrong_okButton),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
