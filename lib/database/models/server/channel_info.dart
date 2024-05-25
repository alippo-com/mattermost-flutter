// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:watermelondb/watermelondb.dart';
import 'package:watermelondb/decorators.dart';
import 'package:mattermost_flutter/constants/database.dart';
import 'package:mattermost_flutter/types/database/models/servers/channel.dart';
import 'package:mattermost_flutter/types/database/models/servers/channel_info_interface.dart';

const CHANNEL = MM_TABLES.SERVER['CHANNEL'];
const CHANNEL_INFO = MM_TABLES.SERVER['CHANNEL_INFO'];

/**
 * ChannelInfo is an extension of the information contained in the Channel table.
 * In a Separation of Concerns approach, ChannelInfo will provide additional information about a channel but on a more
 * specific level.
 */
class ChannelInfoModel extends Model with ChannelInfoInterface {
  /** table (name) : ChannelInfo */
  static final String tableName = CHANNEL_INFO;

  static final Map<String, Association> associations = {
    CHANNEL: Association(type: AssociationType.belongsTo, key: 'id'),
  };

  /** guest_count : The number of guests in this channel */
  @Field('guest_count')
  late int guestCount;

  /** header : The headers at the top of each channel */
  @Field('header')
  late String header;

  /** member_count: The number of members in this channel */
  @Field('member_count')
  late int memberCount;

  /** pinned_post_count : The number of posts pinned in this channel */
  @Field('pinned_post_count')
  late int pinnedPostCount;

  /** files_count : The number of files in this channel */
  @Field('files_count')
  late int filesCount;

  /** purpose: The intention behind this channel */
  @Field('purpose')
  late String purpose;

  /** channel : The lazy query property to the record from CHANNEL table */
  @ImmutableRelation(CHANNEL, 'id')
  late Relation<ChannelModel> channel;
}
