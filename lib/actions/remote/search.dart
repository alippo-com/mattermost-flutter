import 'package:mattermost_flutter/actions/remote/post.dart';
import 'package:mattermost_flutter/constants.dart';
import 'package:mattermost_flutter/database/manager.dart';
import 'package:mattermost_flutter/queries/servers/post.dart';
import 'package:mattermost_flutter/queries/servers/system.dart';
import 'package:mattermost_flutter/queries/servers/thread.dart';
import 'package:mattermost_flutter/utils/general.dart';
import 'package:mattermost_flutter/utils/log.dart';
import 'package:mattermost_flutter/utils/post.dart';
import 'package:mattermost_flutter/utils/post_list.dart';
import 'package:mattermost_flutter/actions/channel.dart';
import 'package:types/models/servers/my_channel.dart';
import 'package:types/models/servers/post.dart';
import 'package:types/models/servers/user.dart';

const MM_TABLES = {
  'SERVER': {
    'DRAFT': 'draft',
    'FILE': 'file',
    'POST': 'post',
    'POSTS_IN_THREAD': 'posts_in_thread',
    'REACTION': 'reaction',
    'THREAD': 'thread',
    'THREAD_PARTICIPANT': 'thread_participant',
    'THREADS_IN_TEAM': 'threads_in_team',
  }
};

Future<Map<String, dynamic>> sendAddToChannelEphemeralPost(
    String serverUrl,
    UserModel user,
    List<String> addedUsernames,
    List<String> messages,
    String channelId,
    {String postRootId = ''}) async {
  try {
    final operator = DatabaseManager.getServerDatabaseAndOperator(serverUrl).operator;
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final posts = addedUsernames.asMap().entries.map((entry) {
      final message = messages[entry.key];
      return PostModel(
        id: generateId(),
        userId: user.id,
        channelId: channelId,
        message: message,
        type: Post.POST_TYPES['EPHEMERAL_ADD_TO_CHANNEL'],
        createAt: timestamp,
        editAt: 0,
        updateAt: timestamp,
        deleteAt: 0,
        isPinned: false,
        originalId: '',
        hashtags: '',
        pendingPostId: '',
        replyCount: 0,
        metadata: {},
        rootId: postRootId,
        props: {
          'username': user.username,
          'addedUsername': entry.value,
        },
      );
    }).toList();

    await operator.handlePosts({
      'actionType': ActionType.POSTS['RECEIVED_NEW'],
      'order': posts.map((p) => p.id).toList(),
      'posts': posts,
    });

    return {'posts': posts};
  } catch (error) {
    logError('Failed sendAddToChannelEphemeralPost', error);
    return {'error': error};
  }
}

Future<Map<String, dynamic>> sendEphemeralPost(
    String serverUrl, String message, String channelId,
    {String rootId = '', String? userId}) async {
  try {
    final dbOperator = DatabaseManager.getServerDatabaseAndOperator(serverUrl);
    final database = dbOperator.database;
    final operator = dbOperator.operator;

    if (channelId.isEmpty) {
      throw Exception('channel Id not defined');
    }

    var authorId = userId ?? await getCurrentUserId(database);

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final post = PostModel(
      id: generateId(),
      userId: authorId,
      channelId: channelId,
      message: message,
      type: Post.POST_TYPES['EPHEMERAL'],
      createAt: timestamp,
      editAt: 0,
      updateAt: timestamp,
      deleteAt: 0,
      isPinned: false,
      originalId: '',
      hashtags: '',
      pendingPostId: '',
      replyCount: 0,
      metadata: {},
      rootId: rootId,
      props: {},
    );

    await fetchPostAuthors(serverUrl, [post], false);
    await operator.handlePosts({
      'actionType': ActionType.POSTS['RECEIVED_NEW'],
      'order': [post.id],
      'posts': [post],
    });

    return {'post': post};
  } catch (error) {
    logError('Failed sendEphemeralPost', error);
    return {'error': error};
  }
}

Future<Map<String, dynamic>> removePost(String serverUrl, PostModel post) async {
  try {
    final dbOperator = DatabaseManager.getServerDatabaseAndOperator(serverUrl);
    final database = dbOperator.database;
    final operator = dbOperator.operator;

    if (post.type == Post.POST_TYPES['COMBINED_USER_ACTIVITY'] && post.props?.systemPostIds != null) {
      final systemPostIds = getPostIdsForCombinedUserActivityPost(post.id);
      final removeModels = <dynamic>[];

      for (var id in systemPostIds) {
        final postModel = await getPostById(database, id);
        if (postModel != null) {
          final preparedPost = await prepareDeletePost(postModel);
          removeModels.addAll(preparedPost);
        }
      }

      if (removeModels.isNotEmpty) {
        await operator.batchRecords(removeModels, 'removePost (combined user activity)');
      }
    } else {
      final postModel = await getPostById(database, post.id);
      if (postModel != null) {
        final preparedPost = await prepareDeletePost(postModel);
        if (preparedPost.isNotEmpty) {
          await operator.batchRecords(preparedPost, 'removePost');
        }
      }
    }

    return {'post': post};
  } catch (error) {
    logError('Failed removePost', error);
    return {'error': error};
  }
}

Future<Map<String, dynamic>> markPostAsDeleted(
    String serverUrl, PostModel post, {bool prepareRecordsOnly = false}) async {
  try {
    final dbOperator = DatabaseManager.getServerDatabaseAndOperator(serverUrl);
    final database = dbOperator.database;
    final operator = dbOperator.operator;
    final dbPost = await getPostById(database, post.id);

    if (dbPost == null) {
      throw Exception('Post not found');
    }

    final model = dbPost.prepareUpdate((p) {
      p.deleteAt = DateTime.now().millisecondsSinceEpoch;
      p.message = '';
      p.messageSource = '';
      p.metadata = null;
      p.props = null;
    });

    if (!prepareRecordsOnly) {
      await operator.batchRecords([dbPost], 'markPostAsDeleted');
    }

    return {'model': model};
  } catch (error) {
    logError('Failed markPostAsDeleted', error);
    return {'error': error};
  }
}

Future<Map<String, dynamic>> storePostsForChannel(
    String serverUrl, String channelId, List<PostModel> posts, List<String> order,
    String previousPostId, String actionType, List<UserModel> authors, {bool prepareRecordsOnly = false}) async {
  try {
    final dbOperator = DatabaseManager.getServerDatabaseAndOperator(serverUrl);
    final database = dbOperator.database;
    final operator = dbOperator.operator;

    final isCRTEnabled = await getIsCRTEnabled(database);
    final models = <dynamic>[];

    final postModels = await operator.handlePosts({
      'actionType': actionType,
      'order': order,
      'posts': posts,
      'previousPostId': previousPostId,
      'prepareRecordsOnly': true,
    });
    models.addAll(postModels);

    if (authors.isNotEmpty) {
      final userModels = await operator.handleUsers(users: authors, prepareRecordsOnly: true);
      models.addAll(userModels);
    }

    final lastFetchedAt = getLastFetchedAtFromPosts(posts);
    MyChannelModel? myChannelModel;

    if (lastFetchedAt != null) {
      final member = await updateMyChannelLastFetchedAt(serverUrl, channelId, lastFetchedAt, true);
      myChannelModel = member['member'];
    }

    var lastPostAt = 0;
    for (var post in posts) {
      final isCrtReply = isCRTEnabled && post.rootId != '';
      if (!isCrtReply) {
        lastPostAt = post.createAt > lastPostAt ? post.createAt : lastPostAt;
      }
    }

    if (lastPostAt != 0) {
      final member = await updateLastPostAt(serverUrl, channelId, lastPostAt, true);
      if (member != null) {
        myChannelModel = member['member'];
      }
    }

    if (myChannelModel != null) {
      models.add(myChannelModel);
    }

    if (isCRTEnabled) {
      final threadModels = await prepareThreadsFromReceivedPosts(operator, posts, false);
      if (threadModels?.isNotEmpty) {
        models.addAll(threadModels);
      }
    }

    if (models.isNotEmpty && !prepareRecordsOnly) {
      await operator.batchRecords(models, 'storePostsForChannel');
    }

    return {'models': models};
  } catch (error) {
    logError('storePostsForChannel', error);
    return {'error': error};
  }
}

Future<List<PostModel>> getPosts(String serverUrl, List<String> ids, {String? sort}) async {
  try {
    final dbOperator = DatabaseManager.getServerDatabaseAndOperator(serverUrl);
    final database = dbOperator.database;
    return queryPostsById(database, ids, sort: sort).fetch();
  } catch (error) {
    return [];
  }
}

Future<Map<String, dynamic>> addPostAcknowledgement(
    String serverUrl, String postId, String userId, int acknowledgedAt, {bool prepareRecordsOnly = false}) async {
  try {
    final dbOperator = DatabaseManager.getServerDatabaseAndOperator(serverUrl);
    final database = dbOperator.database;
    final operator = dbOperator.operator;
    final post = await getPostById(database, postId);

    if (post == null) {
      throw Exception('Post not found');
    }

    final isAckd = post.metadata?.acknowledgements?.any((a) => a['userId'] == userId);
    if (isAckd != null && isAckd) {
      return {'error': false};
    }

    final acknowledgements = [
      ...(post.metadata?.acknowledgements ?? []),
      {
        'userId': userId,
        'acknowledgedAt': acknowledgedAt,
        'postId': postId,
      }
    ];

    final model = post.prepareUpdate((p) {
      p.metadata = {
        ...p.metadata,
        'acknowledgements': acknowledgements,
      };
    });

    if (!prepareRecordsOnly) {
      await operator.batchRecords([model], 'addPostAcknowledgement');
    }

    return {'model': model};
  } catch (error) {
    logError('Failed addPostAcknowledgement', error);
    return {'error': error};
  }
}

Future<Map<String, dynamic>> removePostAcknowledgement(
    String serverUrl, String postId, String userId, {bool prepareRecordsOnly = false}) async {
  try {
    final dbOperator = DatabaseManager.getServerDatabaseAndOperator(serverUrl);
    final database = dbOperator.database;
    final operator = dbOperator.operator;
    final post = await getPostById(database, postId);

    if (post == null) {
      throw Exception('Post not found');
    }

    final model = post.prepareUpdate((p) {
      p.metadata = {
        ...p.metadata,
        'acknowledgements': post.metadata?.acknowledgements?.where((a) => a['userId'] != userId).toList() ?? [],
      };
    });

    if (!prepareRecordsOnly) {
      await operator.batchRecords([model], 'removePostAcknowledgement');
    }

    return {'model': model};
  } catch (error) {
    logError('Failed removePostAcknowledgement', error);
    return {'error': error};
  }
}

Future<Map<String, dynamic>> deletePosts(String serverUrl, List<String> postIds) async {
  try {
    final dbOperator = DatabaseManager.getServerDatabaseAndOperator(serverUrl);
    final database = dbOperator.database;
    final postsFormatted = postIds.map((id) => "'$id'").join(',');

    await database.adapter.unsafeExecuteBatch([
      ['DELETE FROM ${MM_TABLES['SERVER']['POST']} WHERE id IN ($postsFormatted)', []],
      ['DELETE FROM ${MM_TABLES['SERVER']['REACTION']} WHERE post_id IN ($postsFormatted)', []],
      ['DELETE FROM ${MM_TABLES['SERVER']['FILE']} WHERE post_id IN ($postsFormatted)', []],
      ['DELETE FROM ${MM_TABLES['SERVER']['DRAFT']} WHERE root_id IN ($postsFormatted)', []],
      ['DELETE FROM ${MM_TABLES['SERVER']['POSTS_IN_THREAD']} WHERE root_id IN ($postsFormatted)', []],
      ['DELETE FROM ${MM_TABLES['SERVER']['THREAD']} WHERE id IN ($postsFormatted)', []],
      ['DELETE FROM ${MM_TABLES['SERVER']['THREAD_PARTICIPANT']} WHERE thread_id IN ($postsFormatted)', []],
      ['DELETE FROM ${MM_TABLES['SERVER']['THREADS_IN_TEAM']} WHERE thread_id IN ($postsFormatted)', []],
    ]);

    return {'error': false};
  } catch (error) {
    return {'error': error};
  }
}

Future<int> getUsersCountFromMentions(String serverUrl, List<String> mentions) async {
  try {
    final dbOperator = DatabaseManager.getServerDatabaseAndOperator(serverUrl);
    final database = dbOperator.database;
    return await countUsersFromMentions(database, mentions);
  } catch (error) {
    return 0;
  }
}
