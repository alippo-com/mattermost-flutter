// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:watermelondb/watermelondb.dart';
import 'package:watermelondb/decorators.dart';
import 'package:mattermost_flutter/constants/database.dart';
import 'package:mattermost_flutter/types/category_model.dart';
import 'package:mattermost_flutter/types/channel_model.dart';
import 'package:mattermost_flutter/types/my_channel_model.dart';
import 'package:mattermost_flutter/types/category_channel_interface.dart';

/**
 * The CategoryChannel model represents the 'association table' where many categories have channels and many channels are in
 * categories (relationship type N:N)
 */
class CategoryChannelModel extends Model implements CategoryChannelInterface {
  /** table (name) : CategoryChannel */
  static const tableName = MM_TABLES_SERVER.CATEGORY_CHANNEL;

  /** associations : Describes every relationship to this table. */
  static final associations = {
    /** A CategoryChannel belongs to a CATEGORY */
    MM_TABLES_SERVER.CATEGORY: WatermelonDBAssociation(
      type: WatermelonDBAssociationType.belongsTo,
      foreignKey: 'category_id',
    ),

    /** A CategoryChannel has a Channel */
    MM_TABLES_SERVER.CHANNEL: WatermelonDBAssociation(
      type: WatermelonDBAssociationType.belongsTo,
      foreignKey: 'channel_id',
    ),

    /** A CategoryChannel has a MyChannel */
    MM_TABLES_SERVER.MY_CHANNEL: WatermelonDBAssociation(
      type: WatermelonDBAssociationType.belongsTo,
      foreignKey: 'channel_id',
    ),
  };

  /** category_id : The foreign key to the related Category record */
  @Field('category_id')
  late final String categoryId;

  /** channel_id : The foreign key to the related Channel record */
  @Field('channel_id')
  late final String channelId;

  /* sort_order: The sort order for the channel in category */
  @Field('sort_order')
  late final int sortOrder;

  /** category : The related category */
  @Relation('CATEGORY', 'category_id')
  late final Future<CategoryModel> category;

  /** channel : The related channel */
  @ImmutableRelation('CHANNEL', 'channel_id')
  late final Future<ChannelModel> channel;

  /** myChannel : The related myChannel */
  @ImmutableRelation('MY_CHANNEL', 'channel_id')
  late final Future<MyChannelModel> myChannel;
}
