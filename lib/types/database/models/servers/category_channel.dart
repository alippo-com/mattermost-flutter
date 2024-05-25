// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:watermelondb/watermelondb.dart';
import 'package:mattermost_flutter/types/database/models/servers/category.dart';
import 'package:mattermost_flutter/types/database/models/servers/channel.dart';
import 'package:mattermost_flutter/types/database/models/servers/my_channel.dart';

/**
 * The CategoryChannel model represents the 'association table' where many categories have channels and many channels are in
 * categories (relationship type N:N)
 */
class CategoryChannelModel extends Model {
  /** table (name) : CategoryChannel */
  static final String table = 'category_channel';

  /** associations : Describes every relationship to this table. */
  static final Associations associations = {
    'categories': Category(),
    'channels': Channel(),
    'myChannels': MyChannel(),
  };

  /** category_id : The foreign key to the related Category record */
  String categoryId;

  /** channel_id : The foreign key to the related User record */
  String channelId;

  /** sort_order : The order in which the channel displays in the category, if the order is manually set */
  int sortOrder;

  /** category : The related category */
  Relation<CategoryModel> category;

  /** channel : The related channel */
  Relation<ChannelModel> channel;

  /** myChannel : The related myChannel */
  Relation<MyChannelModel> myChannel;

  CategoryChannelModel({
    required this.categoryId,
    required this.channelId,
    required this.sortOrder,
    required this.category,
    required this.channel,
    required this.myChannel,
  });
}

