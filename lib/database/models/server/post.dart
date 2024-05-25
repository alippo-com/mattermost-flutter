// Converted Dart code from TypeScript

import 'package:watermelondb/watermelondb.dart';
import 'package:watermelondb/decorators.dart';
import 'package:mattermost_flutter/constants/database.dart';
import 'package:mattermost_flutter/utils/helpers.dart';
import 'package:mattermost_flutter/types/channel.dart';
import 'package:mattermost_flutter/types/draft.dart';
import 'package:mattermost_flutter/types/file.dart';
import 'package:mattermost_flutter/types/post.dart';
import 'package:mattermost_flutter/types/posts_in_thread.dart';
import 'package:mattermost_flutter/types/reaction.dart';
import 'package:mattermost_flutter/types/thread.dart';
import 'package:mattermost_flutter/types/user.dart';

const CHANNEL = MM_TABLES.SERVER['CHANNEL'];
const DRAFT = MM_TABLES.SERVER['DRAFT'];
const FILE = MM_TABLES.SERVER['FILE'];
const POST = MM_TABLES.SERVER['POST'];
const POSTS_IN_THREAD = MM_TABLES.SERVER['POSTS_IN_THREAD'];
const REACTION = MM_TABLES.SERVER['REACTION'];
const THREAD = MM_TABLES.SERVER['THREAD'];
const USER = MM_TABLES.SERVER['USER'];

class PostModel extends Model implements PostModelInterface {
  static String table = POST;

  static final Map<String, Association> associations = {
    CHANNEL: Association.belongsTo('channel_id'),
    DRAFT: Association.hasMany('root_id'),
    FILE: Association.hasMany('post_id'),
    POSTS_IN_THREAD: Association.hasMany('root_id'),
    REACTION: Association.hasMany('post_id'),
    THREAD: Association.hasMany('id'),
    USER: Association.belongsTo('user_id'),
  };

  @Field('channel_id')
  String channelId;

  @Field('create_at')
  int createAt;

  @Field('delete_at')
  int deleteAt;

  @Field('update_at')
  int updateAt;

  @Field('edit_at')
  int editAt;

  @Field('is_pinned')
  bool isPinned;

  @Field('message')
  String message;

  @Field('message_source')
  String messageSource;

  @Json('metadata', safeParseJSON)
  PostMetadata metadata;

  @Field('original_id')
  String originalId;

  @Field('pending_post_id')
  String pendingPostId;

  @Field('previous_post_id')
  String previousPostId;

  @Field('root_id')
  String rootId;

  @Field('type')
  PostType type;

  @Field('user_id')
  String userId;

  @Json('props', safeParseJSON)
  dynamic props;

  @Lazy
  Query<DraftModel> get drafts => collections.get<DraftModel>(DRAFT).query(Q.on(POST, 'id', this.id));

  @Lazy
  Query<PostModel> get root => collection.query(Q.where('id', this.rootId));

  @Lazy
  Query<PostInThreadModel> get postsInThread => collections.get<PostInThreadModel>(POSTS_IN_THREAD).query(
    Q.where('root_id', this.rootId ?? this.id),
    Q.sortBy('latest', Q.desc),
    Q.take(1),
  );

  @Children(FILE)
  Query<FileModel> files;

  @Children(REACTION)
  Query<ReactionModel> reactions;

  @ImmutableRelation(USER, 'user_id')
  Relation<UserModel> author;

  @ImmutableRelation(CHANNEL, 'channel_id')
  Relation<ChannelModel> channel;

  @ImmutableRelation(THREAD, 'id')
  Relation<ThreadModel> thread;

  Future<void> destroyPermanently() async {
    await reactions.destroyAllPermanently();
    await files.destroyAllPermanently();
    await drafts.destroyAllPermanently();
    await collections.get(POSTS_IN_THREAD).query(Q.where('root_id', this.id)).destroyAllPermanently();
    try {
      final thread = await this.thread.fetch();
      if (thread != null) {
        await thread.destroyPermanently();
        await thread.participants.destroyAllPermanently();
        await thread.threadsInTeam.destroyAllPermanently();
      }
    } catch (e) {
      // there is no thread record for this post
    }
    super.destroyPermanently();
  }

  Future<bool> hasReplies() async {
    if (this.rootId == null) {
      return (await postsInThread.fetch()).length > 0;
    }

    final root = await this.root.fetch();
    if (root.isNotEmpty) {
      return (await root[0].postsInThread.fetch()).length > 0;
    }

    return false;
  }

  Future<Post> toApi() async {
    return Post(
      id: this.id,
      createAt: this.createAt,
      updateAt: this.updateAt,
      editAt: this.editAt,
      deleteAt: this.deleteAt,
      isPinned: this.isPinned,
      userId: this.userId,
      channelId: this.channelId,
      rootId: this.rootId,
      originalId: this.originalId,
      message: this.message,
      messageSource: this.messageSource,
      type: this.type,
      props: this.props,
      pendingPostId: this.pendingPostId,
      fileIds: await this.files.fetchIds(),
      metadata: this.metadata ?? PostMetadata(),
      hashtags: '',
      replyCount: 0,
    );
  }
}
