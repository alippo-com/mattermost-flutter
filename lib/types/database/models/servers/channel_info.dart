// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:watermelondb/watermelondb.dart';
import 'package:watermelondb/Relation.dart';
import 'package:mattermost_flutter/types/database/models/servers/channel.dart';

class ChannelInfoModel extends Model {
  static final table = 'ChannelInfo';

  int guestCount;
  String header;
  int memberCount;
  int pinnedPostCount;
  int filesCount;
  String purpose;
  Relation<ChannelModel> channel;

  ChannelInfoModel({
    required this.guestCount,
    required this.header,
    required this.memberCount,
    required this.pinnedPostCount,
    required this.filesCount,
    required this.purpose,
    required this.channel,
  });
}
