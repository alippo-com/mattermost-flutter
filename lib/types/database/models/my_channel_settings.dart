// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:watermelondb/watermelondb.dart';
import 'package:mattermost_flutter/types/database/models/my_channel.dart';

/**
 * The MyChannelSettings model represents the specific user's configuration to
 * the channel this user belongs to.
 */
class MyChannelSettingsModel extends Model {
  static const String table = 'MyChannelSettings';

  // Configurations with regards to this channel
  Map<String, dynamic> notifyProps;

  // The relation pointing to the MY_CHANNEL table
  Relation<MyChannelModel> myChannel;

  MyChannelSettingsModel({
    required this.notifyProps,
    required this.myChannel,
  });
}
