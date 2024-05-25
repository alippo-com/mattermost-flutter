// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

Future<Map<String, bool>> privateChannelJoinPrompt(BuildContext context, String displayName) {
  return showDialog<Map<String, bool>>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(AppLocalizations.of(context)!.permalinkShowDialogWarnTitle),
        content: Text(AppLocalizations.of(context)!.permalinkShowDialogWarnDescription(displayName)),
        actions: <Widget>[
          TextButton(
            child: Text(AppLocalizations.of(context)!.permalinkShowDialogWarnCancel),
            onPressed: () {
              Navigator.of(context).pop({'join': false});
            },
          ),
          TextButton(
            child: Text(AppLocalizations.of(context)!.permalinkShowDialogWarnJoin),
            onPressed: () {
              Navigator.of(context).pop({'join': true});
            },
          ),
        ],
      );
    },
  );
}
