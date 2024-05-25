import 'package:watermelondb/watermelondb.dart';
import 'package:watermelondb/decorators.dart';
import 'package:mattermost_flutter/types/database/models/servers/channel.dart';
import 'package:mattermost_flutter/types/database/models/servers/group.dart';
import 'package:mattermost_flutter/constants/database.dart';
import 'package:mattermost_flutter/types/database/models/servers/group_channel_interface.dart';

const CHANNEL = MM_TABLES.SERVER.CHANNEL;
const GROUP = MM_TABLES.SERVER.GROUP;
const GROUP_CHANNEL = MM_TABLES.SERVER.GROUP_CHANNEL;

/// The GroupChannel model represents the 'association table' where many groups have channels and many channels are in
/// groups (relationship type N:N)
class GroupChannelModel extends Model implements GroupChannelInterface {
  static String table = GROUP_CHANNEL;

  static final Map<String, Association> associations = {
    GROUP: Association.belongsTo(GROUP, 'group_id'),
    CHANNEL: Association.belongsTo(CHANNEL, 'channel_id'),
  };

  @Field('group_id')
  String groupId;

  @Field('channel_id')
  String channelId;

  @Field('created_at')
  int createdAt;

  @Field('updated_at')
  int updatedAt;

  @Field('deleted_at')
  int deletedAt;

  @immutableRelation(GROUP, 'group_id')
  final group = HasOne<GroupModel>();

  @immutableRelation(CHANNEL, 'channel_id')
  final channel = HasOne<ChannelModel>();
}
