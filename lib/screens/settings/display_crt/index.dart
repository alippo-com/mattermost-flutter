// Converted from index.ts
// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:mattermost_flutter/types/database/models/servers/user.dart';
import 'package:mattermost_flutter/types/screens/navigation.dart';
display_crt.dart';
import 'package:mattermost_flutter/types/database/database.dart';

class DisplayCRTContainer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        StreamProvider<UserModel>(
          create: (context) => observeCurrentUserId(Database()),
          initialData: UserModel(),
        ),
        StreamProvider<bool>(
          create: (context) => observeIsCRTEnabled(Database()),
          initialData: false,
        ),
      ],
      child: DisplayCRT(),
    );
  }
}
