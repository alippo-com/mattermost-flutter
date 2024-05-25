import 'package:watermelondb/watermelondb.dart';
import 'package:watermelondb/decorators.dart';
import 'package:mattermost_flutter/types/channel.dart';
import 'package:mattermost_flutter/types/draft.dart';
import 'package:mattermost_flutter/types/file.dart';
import 'package:mattermost_flutter/types/posts_in_thread.dart';
import 'package:mattermost_flutter/types/reaction.dart';
import 'package:mattermost_flutter/types/thread.dart';
import 'package:mattermost_flutter/types/user.dart';
import 'package:mattermost_flutter/types/team.dart';

class CategoryModel extends Model {
  static String table = 'category';

  static Associations associations = {
    'category_channel': (categoryChannel) => categoryChannel.hasMany(CategoryModel.table),
    'team': (team) => team.belongsTo(CategoryModel.table, 'team_id'),
  };

  @Column(name: 'display_name')
  String displayName;

  @Column(name: 'type')
  String type;

  @Column(name: 'sort_order')
  int sortOrder;

  @Column(name: 'sorting')
  String sorting;

  @Column(name: 'collapsed')
  bool collapsed;

  @Column(name: 'muted')
  bool muted;

  @Column(name: 'team_id')
  String teamId;

  @ImmutableRelation('team')
  final team = Relation<TeamModel>;

  @Children('category_channel')
  final categoryChannels = Query<CategoryChannelModel>;

  @Lazy
  Query<CategoryChannelModel> get categoryChannelsBySortOrder => categoryChannels.collection
      .query(
        Q.on('my_channel', Q.where('id', Q.notEq(''))),
        Q.where('category_id', id),
        Q.sortBy('sort_order', Q.asc),
      );

  @Lazy
  Query<ChannelModel> get channels => collections
      .get<ChannelModel>('channel')
      .query(
        Q.experimentalJoinTables(['my_channel', 'category_channel']),
        Q.on('category_channel',
          Q.and(
            Q.on('my_channel', Q.where('id', Q.notEq(''))),
            Q.where('category_id', id),
          ),
        ),
      );

  @Lazy
  Query<MyChannelModel> get myChannels => collections
      .get<MyChannelModel>('my_channel')
      .query(
        Q.experimentalJoinTables(['channel', 'category_channel']),
        Q.on('category_channel',
          Q.and(
            Q.on('channel', Q.where('create_at', Q.gte(0))),
            Q.where('category_id', id),
          ),
        ),
        Q.sortBy('last_post_at', Q.desc),
      );

  Stream<bool> observeHasChannels(bool canViewArchived, String channelId) {
    return channels.observeWithColumns(['delete_at']).map((channels) {
      if (canViewArchived) {
        return channels.where((c) => c.deleteAt == 0 || c.id == channelId).isNotEmpty;
      }
      return channels.where((c) => c.deleteAt == 0).isNotEmpty;
    }).distinct();
  }

  Future<CategoryWithChannels> toCategoryWithChannels() async {
    final categoryChannels = await this.categoryChannels.fetch();
    final orderedChannelIds = categoryChannels
        .sorted((a, b) => a.sortOrder - b.sortOrder)
        .map((cc) => cc.channelId)
        .toList();

    return CategoryWithChannels(
      channelIds: orderedChannelIds,
      id: id,
      teamId: teamId,
      displayName: displayName,
      sortOrder: sortOrder,
      sorting: sorting,
      type: type,
      muted: muted,
      collapsed: collapsed,
    );
  }
}

class CategoryWithChannels {
  List<String> channelIds;
  String id;
  String teamId;
  String displayName;
  int sortOrder;
  String sorting;
  String type;
  bool muted;
  bool collapsed;

  CategoryWithChannels({
    required this.channelIds,
    required this.id,
    required this.teamId,
    required this.displayName,
    required this.sortOrder,
    required this.sorting,
    required this.type,
    required this.muted,
    required this.collapsed,
  });
}
