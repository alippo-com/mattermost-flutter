// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:watermelondb/watermelondb.dart';
import 'package:watermelondb/decorators.dart';
import 'package:mattermost_flutter/types/database/models/servers/channel.dart';
import 'package:mattermost_flutter/types/database/models/servers/my_channel_settings.dart';
import 'package:mattermost_flutter/types/database/models/servers/my_channel_interface.dart';
import 'package:mattermost_flutter/constants/database.dart';

const CATEGORY_CHANNEL = MM_TABLES.SERVER.CATEGORY_CHANNEL;
const CHANNEL = MM_TABLES.SERVER.CHANNEL;
const MY_CHANNEL = MM_TABLES.SERVER.MY_CHANNEL;
const MY_CHANNEL_SETTINGS = MM_TABLES.SERVER.MY_CHANNEL_SETTINGS;

class MyChannelModel extends Model implements MyChannelModelInterface {
  static String table = MY_CHANNEL;

  static final Map<String, Association> associations = {
    CHANNEL: Association.belongsTo(CHANNEL, 'id'),
    CATEGORY_CHANNEL: Association.hasMany(CATEGORY_CHANNEL, 'channel_id'),
    MY_CHANNEL_SETTINGS: Association.hasMany(MY_CHANNEL_SETTINGS, 'id'),
  };

  @Field('last_post_at')
  int lastPostAt;

  @Field('last_fetched_at')
  int lastFetchedAt;

  @Field('last_viewed_at')
  int lastViewedAt;

  @Field('manually_unread')
  bool manuallyUnread;

  @Field('message_count')
  int messageCount;

  @Field('mentions_count')
  int mentionsCount;

  @Field('is_unread')
  bool isUnread;

  @Field('roles')
  String roles;

  @Field('viewed_at')
  int viewedAt;

  @immutableRelation(CHANNEL, 'id')
  final memberChannel = HasOne<ChannelModel>();

  @immutableRelation(MY_CHANNEL_SETTINGS, 'id')
  final memberSettings = HasOne<MyChannelSettingsModel>();

  Future<void> destroyPermanently() async {
    final settings = await memberSettings.fetch();
    settings?.destroyPermanently();
    super.destroyPermanently();
  }

  void resetPreparedState() {
    _preparedState = null;
  }
}
