// Converted from index.ts
// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

display_crt.dart';

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
