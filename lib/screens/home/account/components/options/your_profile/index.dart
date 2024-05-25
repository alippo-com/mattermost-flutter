// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:mattermost_flutter/components/option_item.dart';
import 'package:mattermost_flutter/constants.dart';
import 'package:mattermost_flutter/utils/tap.dart';
import 'package:mattermost_flutter/screens/navigation.dart';
import 'package:mattermost_flutter/types/theme.dart';
import 'package:mattermost_flutter/types/system.dart';

class YourProfile extends StatelessWidget {
  final bool isTablet;
  final Theme theme;

  YourProfile({required this.isTablet, required this.theme});

  @override
  Widget build(BuildContext context) {
    final intl = AppLocalizations.of(context)!;

    void openProfile() {
      preventDoubleTap(() {
        if (isTablet) {
          SystemChannels.platform.invokeMethod('emit', {
            'event': Events.ACCOUNT_SELECT_TABLET_VIEW,
            'screen': Screens.EDIT_PROFILE,
          });
        } else {
          showModal(
            context,
            Screens.EDIT_PROFILE,
            intl.translate('mobile.screen.your_profile', defaultMessage: 'Your Profile'),
          );
        }
      });
    }

    return OptionItem(
      icon: ACCOUNT_OUTLINE_IMAGE,
      label: intl.translate('account.your_profile', defaultMessage: 'Your Profile'),
      testID: 'account.your_profile.option',
      type: 'default',
      action: openProfile,
    );
  }
}
