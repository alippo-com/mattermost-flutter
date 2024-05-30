import 'package:watermelon_db/watermelon_db.dart';
import 'package:mattermost_flutter/types/database/models/servers/category_channel.dart';
import 'package:mattermost_flutter/types/database/models/servers/channel_info.dart';
import 'package:mattermost_flutter/types/database/models/servers/channel_membership.dart';
import 'package:mattermost_flutter/types/database/models/servers/draft.dart';
import 'package:mattermost_flutter/types/database/models/servers/my_channel.dart';
import 'package:mattermost_flutter/types/database/models/servers/post.dart';
import 'package:mattermost_flutter/types/database/models/servers/posts_in_channel.dart';

/**
 * The Channel model represents a channel in the Mattermost app.
 */
class ChannelModel extends Model {
  /** table (name) : Channel */
  static const table = 'Channel';

  /** associations : Describes every relationship to this table. */
  static final Map<String, Association> associations = {
    'members': Query<ChannelMembershipModel>(),
    'drafts': Query<DraftModel>(),
    'posts': Query<PostModel>(),
    'postsInChannel': Query<PostsInChannelModel>(),
    'team': Relation<TeamModel>(),
    'creator': Relation<UserModel>(),
    'info': Relation<ChannelInfoModel>(),
    'membership': Relation<MyChannelModel>(),
    'categoryChannel': Relation<CategoryChannelModel>(),
  };

  /** create_at : The creation date for this channel */
  int createAt;

  /** creator_id : The user who created this channel */
  String creatorId;

  /** delete_at : The deletion/archived date of this channel */
  int deleteAt;

  /** update_at : The timestamp to when this channel was last updated on the server */
  int updateAt;

  /** display_name : The channel display name (e.g. Town Square ) */
  String displayName;

  /** is_group_constrained : If a channel is restricted to certain groups, this boolean will be true and only members of that group have access to this team. Hence indicating that the members of this channel are managed by groups. */
  bool isGroupConstrained;

  /** name : The name of the channel (e.g town-square) */
  String name;

  /** shared: determines if it is a shared channel with another organization */
  bool shared;

  /** team_id : The team to which this channel belongs. It can be empty for direct/group message. */
  String teamId;

  /** type : The type of the channel ( e.g. G: group messages, D: direct messages, P: private channel and O: public channel) */
  ChannelType type;

  /** members : Users belonging to this channel */
  Query<ChannelMembershipModel> members;

  /** drafts : All drafts for this channel */
  Query<DraftModel> drafts;

  /** posts : All posts made in the channel */
  Query<PostModel> posts;

  /** postsInChannel : a section of the posts for that channel bounded by a range */
  Query<PostsInChannelModel> postsInChannel;

  /** team : The TEAM to which this CHANNEL belongs */
  Relation<TeamModel> team;

  /** creator : The USER who created this CHANNEL */
  Relation<UserModel> creator;

  /** info : Query returning extra information about this channel from the CHANNEL_INFO table */
  Relation<ChannelInfoModel> info;

  /** membership : Query returning the membership data for the current user if it belongs to this channel */
  Relation<MyChannelModel> membership;

  /** categoryChannel: category of this channel */
  Relation<CategoryChannelModel> categoryChannel;

  ChannelModel({
    required this.createAt,
    required this.creatorId,
    required this.deleteAt,
    required this.updateAt,
    required this.displayName,
    required this.isGroupConstrained,
    required this.name,
    required this.shared,
    required this.teamId,
    required this.type,
    required this.members,
    required this.drafts,
    required this.posts,
    required this.postsInChannel,
    required this.team,
    required this.creator,
    required this.info,
    required this.membership,
    required this.categoryChannel,
  });

  Map<String, dynamic> toApi() {
    return {
      'createAt': createAt,
      'creatorId': creatorId,
      'deleteAt': deleteAt,
      'updateAt': updateAt,
      'displayName': displayName,
      'isGroupConstrained': isGroupConstrained,
      'name': name,
      'shared': shared,
      'teamId': teamId,
      'type': type,
    };
  }
}
