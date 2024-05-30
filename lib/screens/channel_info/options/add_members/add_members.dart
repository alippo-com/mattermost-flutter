// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mattermost_flutter/constants.dart';
import 'package:mattermost_flutter/types/user_custom_status.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/widgets/custom_status/clear_button.dart';
import 'package:mattermost_flutter/widgets/custom_status/custom_status_expiry.dart';
import 'package:mattermost_flutter/widgets/formatted_text.dart';
import 'package:mattermost_flutter/widgets/custom_status/custom_status_text.dart';
import 'package:mattermost_flutter/widgets/option_item.dart';
import 'package:mattermost_flutter/utils/tap.dart';
import 'package:mattermost_flutter/screens/channel_add_members/channel_add_members.dart';

class AddMembers extends StatelessWidget {
  final String channelId;
  final String displayName;

  AddMembers({
    required this.channelId,
    required this.displayName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = Intl.message('Add members', name: 'channel_info.add_members');

    void goToAddMembers() async {
      final options = await getHeaderOptions(theme, displayName, true);
      goToScreen(Screens.CHANNEL_ADD_MEMBERS, title, {'channelId': channelId, 'inModal': true}, options);
    }

    return OptionItem(
      action: preventDoubleTap(goToAddMembers),
      label: title,
      icon: Icons.account_plus_outline,
      type: Platform.isIOS ? 'arrow' : 'default',
      testID: 'channel_info.options.add_members.option',
    );
  }
}
