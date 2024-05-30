// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

// Adjusted import for Flutter
import 'package:watermelondb/watermelondb.dart';
import 'package:watermelondb/associations.dart';

/**
 * The MyChannelSettings model represents the specific user's configuration to
 * the channel this user belongs to.
 */
class MyChannelSettingsModel extends Model {
  /** table (name) : MyChannelSettings */
  static const String tableName = 'MyChannelSettings';

  /** notify_props : Configurations with regards to this channel */
  Map<String, dynamic> notifyProps;

  /** myChannel : The relation pointing to the MY_CHANNEL table */
  final myChannel = HasOne<MyChannelModel>();

  MyChannelSettingsModel({
    required this.notifyProps,
  });
}

