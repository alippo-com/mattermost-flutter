
import 'package:watermelondb/watermelondb.dart';
import 'package:mattermost_flutter/types/channel.dart';
import 'package:mattermost_flutter/types/draft.dart';
import 'package:mattermost_flutter/types/file.dart';
import 'package:mattermost_flutter/types/posts_in_thread.dart';
import 'package:mattermost_flutter/types/reaction.dart';
import 'package:mattermost_flutter/types/thread.dart';
import 'package:mattermost_flutter/types/user.dart';

class PostModel extends Model {
  static String table = 'posts';
  static Associations associations = {
    ChannelModel.table: (channel) => channel.hasMany(PostModel.table),
    DraftModel.table: (draft) => draft.hasMany(PostModel.table),
    FileModel.table: (file) => file.hasMany(PostModel.table),
    PostsInThreadModel.table: (postsInThread) => postsInThread.hasMany(PostModel.table),
    ReactionModel.table: (reaction) => reaction.hasMany(PostModel.table),
    ThreadModel.table: (thread) => thread.hasMany(PostModel.table),
    UserModel.table: (user) => user.hasMany(PostModel.table),
  };

  @Column(name: 'channel_id')
  String channelId;

  @Column(name: 'create_at')
  int createAt;

  @Column(name: 'delete_at')
  int deleteAt;

  @Column(name: 'update_at')
  int updateAt;

  @Column(name: 'edit_at')
  int editAt;

  @Column(name: 'is_pinned')
  bool isPinned;

  @Column(name: 'message')
  String message;

  @Column(name: 'message_source')
  String messageSource;

  @Column(name: 'metadata')
  PostMetadata metadata;

  @Column(name: 'original_id')
  String originalId;

  @Column(name: 'pending_post_id')
  String pendingPostId;

  @Column(name: 'previous_post_id')
  String previousPostId;

  @HasMany(PostModel)
  Query<PostModel> root;

  @Column(name: 'root_id')
  String rootId;

  @Column(name: 'type')
  String type;

  @Column(name: 'user_id')
  String userId;

  @Column(name: 'props')
  dynamic props;

  @HasMany(DraftModel)
  Query<DraftModel> drafts;

  @HasMany(FileModel)
  Query<FileModel> files;

  @HasMany(PostsInThreadModel)
  Query<PostsInThreadModel> postsInThread;

  @HasMany(ReactionModel)
  Query<ReactionModel> reactions;

  @BelongsTo(UserModel)
  Relation<UserModel> author;

  @BelongsTo(ChannelModel)
  Relation<ChannelModel> channel;

  @BelongsTo(ThreadModel)
  Relation<ThreadModel> thread;

  Future<bool> hasReplies() async {
    // Implement the actual logic to determine if the post is part of a thread
  }

  Future<Post> toApi() async {
    // Implement the actual logic to convert the post to an API format
  }
}
