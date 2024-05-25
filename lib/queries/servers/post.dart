// post.dart

import 'package:watermelondb/watermelondb.dart';
import 'package:rxdart/rxdart.dart';

import 'package:mattermost_flutter/constants/database.dart';
import 'package:mattermost_flutter/types/servers/post.dart';
import 'package:mattermost_flutter/types/servers/posts_in_channel.dart';
import 'package:mattermost_flutter/types/servers/posts_in_thread.dart';
import 'package:mattermost_flutter/utils/helpers.dart';

import 'group.dart';
import 'preference.dart';
import 'system.dart';
import 'user.dart';

const POST = MM_TABLES.SERVER.POST;
const POSTS_IN_CHANNEL = MM_TABLES.SERVER.POSTS_IN_CHANNEL;
const POSTS_IN_THREAD = MM_TABLES.SERVER.POSTS_IN_THREAD;

Future<List<Model>> prepareDeletePost(PostModel post) async {
  final preparedModels = <Model>[post.prepareDestroyPermanently()];
  final relations = [post.drafts, post.files, post.reactions];
  for (final models in relations) {
    try {
      for (final m in models) {
        preparedModels.add(m.prepareDestroyPermanently());
      }
    } catch (e) {
      // Record not found, do nothing
    }
  }

  if (post.rootId == null) {
    try {
      final postsInThread = await post.postsInThread.fetch();
      if (postsInThread != null) {
        for (final m in postsInThread) {
          preparedModels.add(m.prepareDestroyPermanently());
        }
      }
    } catch (e) {
      // Record not found, do nothing
    }
  }

  try {
    final thread = await post.thread.fetch();
    if (thread != null) {
      final participants = await thread.participants.fetch();
      if (participants.isNotEmpty) {
        preparedModels.addAll(participants.map((p) => p.prepareDestroyPermanently()));
      }
      final threadsInTeam = await thread.threadsInTeam.fetch();
      if (threadsInTeam.isNotEmpty) {
        preparedModels.addAll(threadsInTeam.map((t) => t.prepareDestroyPermanently()));
      }
      preparedModels.add(thread.prepareDestroyPermanently());
    }
  } catch (e) {
    // Thread not found, do nothing
  }

  return preparedModels;
}

Future<PostModel?> getPostById(Database database, String postId) async {
  try {
    final postModel = await database.get<PostModel>(POST).find(postId);
    return postModel;
  } catch (e) {
    return null;
  }
}

Observable<PostModel?> observePost(Database database, String postId) {
  return database.get<PostModel>(POST).query(Q.where('id', postId), Q.take(1)).observe().switchMap(
        (result) => result.isNotEmpty ? result.first.observe() : Observable.of(null),
      );
}

Observable<UserModel?> observePostAuthor(Database database, PostModel post) {
  return observeUser(database, post.userId);
}

Observable<bool> observePostSaved(Database database, String postId) {
  return querySavedPostsPreferences(database, postId)
      .observeWithColumns(['value'])
      .switchMap((pref) => Observable.of(pref.first?.value == 'true'));
}

Query<PostInChannelModel> queryPostsInChannel(Database database, String channelId) {
  return database.get<PostInChannelModel>(POSTS_IN_CHANNEL).query(
        Q.where('channel_id', channelId),
        Q.sortBy('latest', Q.desc),
      );
}

Query<PostsInThreadModel> queryPostsInThread(Database database, String rootId, {bool sorted = false, bool includeDeleted = false}) {
  final clauses = <Q.Clause>[Q.where('root_id', rootId)];
  if (!includeDeleted) {
    clauses.insert(0, Q.experimentalJoinTables([POST]));
    clauses.add(Q.on(POST, 'delete_at', Q.eq(0)));
  }

  if (sorted) {
    clauses.add(Q.sortBy('latest', Q.desc));
  }
  return database.get<PostsInThreadModel>(POSTS_IN_THREAD).query(...clauses);
}

Query<PostModel> queryPostReplies(Database database, String rootId, {bool excludeDeleted = true}) {
  final clauses = <Q.Clause>[Q.where('root_id', rootId)];
  if (excludeDeleted) {
    clauses.add(Q.where('delete_at', Q.eq(0)));
  }
  return database.get<PostModel>(POST).query(...clauses);
}

Future<List<PostModel>> getRecentPostsInThread(Database database, String rootId) async {
  final chunks = await queryPostsInThread(database, rootId, sorted: true, includeDeleted: true).fetch();
  if (chunks.isNotEmpty) {
    final recent = chunks.first;
    final post = await getPostById(database, rootId);
    if (post != null) {
      return queryPostsChunk(database, post.channelId, recent.earliest, recent.latest).fetch();
    }
  }
  return [];
}

Future<PostModel?> getLastPostInThread(Database database, String rootId) async {
  final chunks = await queryPostsInThread(database, rootId, sorted: true, includeDeleted: true).fetch();
  if (chunks.isNotEmpty) {
    final recent = chunks.first;
    final post = await getPostById(database, rootId);
    if (post != null) {
      final posts = await queryPostsChunk(database, rootId, recent.earliest, recent.latest, limit: 1).fetch();
      return posts.first;
    }
  }
  return null;
}

Query<PostModel> queryPostsChunk(Database database, String id, int earliest, int latest, {bool inThread = false, bool includeDeleted = false, int limit = 0}) {
  final conditions = <Q.Where>[Q.where('create_at', Q.between(earliest, latest))];
  if (inThread) {
    conditions.add(Q.where('root_id', id));
  } else {
    conditions.add(Q.where('channel_id', id));
  }

  if (!includeDeleted) {
    conditions.add(Q.where('delete_at', Q.eq(0)));
  }

  final clauses = <Q.Clause>[
    Q.and(...conditions),
    Q.sortBy('create_at', Q.desc),
  ];

  if (limit > 0) {
    clauses.add(Q.take(limit));
  }

  return database.get<PostModel>(POST).query(...clauses);
}

Future<List<PostModel>> getRecentPostsInChannel(Database database, String channelId, {bool includeDeleted = false}) async {
  final chunks = await queryPostsInChannel(database, channelId).fetch();
  if (chunks.isNotEmpty) {
    final recent = chunks.first;
    return queryPostsChunk(database, channelId, recent.earliest, recent.latest, includeDeleted: includeDeleted).fetch();
  }
  return [];
}

Query<PostModel> queryPostsById(Database database, List<String> postIds, {Q.SortOrder? sort}) {
  final clauses = <Q.Clause>[Q.where('id', Q.oneOf(postIds))];
  if (sort != null) {
    clauses.add(Q.sortBy('create_at', sort));
  }
  return database.get<PostModel>(POST).query(...clauses);
}

Query<PostModel> queryPostsBetween(Database database, int earliest, int latest, {Q.SortOrder? sort, String? userId, String? channelId, String? rootId}) {
  final andClauses = <Q.Clause>[Q.where('create_at', Q.between(earliest, latest))];
  if (channelId != null) {
    andClauses.add(Q.where('channel_id', channelId));
  }

  if (userId != null) {
    andClauses.add(Q.where('user_id', userId));
  }

  if (rootId != null) {
    andClauses.add(Q.where('root_id', rootId));
  }

  final clauses = <Q.Clause>[Q.and(...andClauses)];
  if (sort != null) {
    clauses.add(Q.sortBy('create_at', sort));
  }
  return database.get<PostModel>(POST).query(...clauses);
}

Query<PostModel> queryPinnedPostsInChannel(Database database, String channelId) {
  return database.get<PostModel>(POST).query(
        Q.and(
          Q.where('channel_id', channelId),
          Q.where('is_pinned', Q.eq(true)),
        ),
        Q.sortBy('create_at', Q.asc),
      );
}

Observable<List<PostModel>> observePinnedPostsInChannel(Database database, String channelId) {
  return queryPinnedPostsInChannel(database, channelId).observe();
}

Observable<Set<String>> observeSavedPostsByIds(Database database, List<String> postIds) {
  return querySavedPostsPreferences(database).extend(
        Q.where('name', Q.oneOf(postIds)),
      ).observeWithColumns(['name']).switchMap(
        (prefs) => Observable.of(prefs.map((p) => p.name).toSet()),
      );
}

Future<bool> getIsPostPriorityEnabled(Database database) async {
  final cfg = await getConfigValue(database, 'PostPriority');
  return cfg == 'true';
}

Future<bool> getIsPostAcknowledgementsEnabled(Database database) async {
  final cfg = await getConfigValue(database, 'PostAcknowledgements');
  return cfg == 'true';
}

Observable<bool> observeIsPostPriorityEnabled(Database database) {
  return observeConfigBooleanValue(database, 'PostPriority');
}

Observable<bool> observeIsPostAcknowledgementsEnabled(Database database) {
  return observeConfigBooleanValue(database, 'PostAcknowledgements');
}

Observable<bool> observePersistentNotificationsEnabled(Database database) {
  final user = observeCurrentUser(database);
  final enabledForAll = observeConfigBooleanValue(database, 'AllowPersistentNotifications');
  final enabledForGuests = observeConfigBooleanValue(database, 'AllowPersistentNotificationsForGuests');
  return user.combineLatestWith([enabledForAll, enabledForGuests]).switchMap(
        (values) {
          final u = values[0];
          final forAll = values[1];
          final forGuests = values[2];
          if (u?.isGuest == true) {
            return Observable.of(forAll && forGuests);
          }
          return Observable.of(forAll);
        },
      ).distinct();
}

Future<int> countUsersFromMentions(Database database, List<String> mentions) async {
  final groupsQuery = queryGroupsByNames(database, mentions).fetch();
  final usersQuery = queryUsersByUsername(database, mentions).fetchCount();
  final results = await Future.wait([groupsQuery, usersQuery]);
  final groups = results[0] as List<GroupModel>;
  final usersCount = results[1] as int;
  return groups.fold(usersCount, (acc, v) => acc + v.memberCount);
}
