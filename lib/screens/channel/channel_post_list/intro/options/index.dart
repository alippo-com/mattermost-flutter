// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:mattermost_flutter/components/channel_actions/add_members_box.dart';
import 'package:mattermost_flutter/components/channel_actions/favorite_box.dart';
import 'package:mattermost_flutter/components/channel_actions/info_box.dart';
import 'package:mattermost_flutter/components/channel_actions/set_header_box.dart';

class IntroOptions extends StatelessWidget {
  final String channelId;
  final bool? header;
  final bool? favorite;
  final bool? canAddMembers;

  const IntroOptions({
    Key? key,
    required this.channelId,
    this.header,
    this.favorite,
    this.canAddMembers,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8, top: 28),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (canAddMembers ?? false)
            AddMembersBox(
              channelId: channelId,
              containerStyle: itemStyle.copyWith(margin: const EdgeInsets.only(right: 8)),
              testID: 'channel_post_list.intro_options.add_members.action',
              inModal: false,
              height: itemHeight,
              width: itemWidth,
              padding: itemContainerStyle,
            ),
          if (header ?? false)
            SetHeaderBox(
              channelId: channelId,
              containerStyle: itemStyle.copyWith(margin: const EdgeInsets.only(right: 8)),
              testID: 'channel_post_list.intro_options.set_header.action',
              height: itemHeight,
              width: itemWidth,
              padding: itemContainerStyle,
            ),
          if (favorite ?? false)
            FavoriteBox(
              channelId: channelId,
              containerStyle: itemStyle.copyWith(margin: const EdgeInsets.only(right: 8)),
              testID: 'channel_post_list.intro_options',
              height: itemHeight,
              width: itemWidth,
              padding: itemContainerStyle,
            ),
          InfoBox(
            channelId: channelId,
            containerStyle: itemStyle,
            testID: 'channel_post_list.intro_options.channel_info.action',
            height: itemHeight,
            width: itemWidth,
            padding: itemContainerStyle,
          ),
        ],
      ),
    );
  }

  static const itemStyle = BoxDecoration(
    borderRadius: BorderRadius.all(Radius.circular(4)),
  );

  static const itemContainerStyle = EdgeInsets.symmetric(horizontal: 16, vertical: 12);
  static const itemHeight = 70.0;
  static const itemWidth = 112.0;
}
