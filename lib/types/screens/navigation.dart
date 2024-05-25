// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:mattermost_flutter/types/constants.dart';
import 'package:mattermost_flutter/types/navigation/options_top_bar_button.dart';

class NavButtons {
  List<OptionsTopBarButton>? leftButtons;
  List<OptionsTopBarButton>? rightButtons;

  NavButtons({this.leftButtons, this.rightButtons});
}

typedef AvailableScreens = Screens;
