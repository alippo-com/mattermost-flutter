// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

// ignore_for_file: max_length

import 'package:mattermost_flutter/constants/database.dart';
import 'package:mattermost_flutter/database/operator/app_data_operator.dart';
import 'package:mattermost_flutter/database/operator/server_data_operator.dart';
import 'package:nozbe/watermelondb/watermelondb.dart';
import 'package:nozbe/watermelondb/model.dart';
import 'package:nozbe/watermelondb/query_description.dart';
import 'package:nozbe/watermelondb/types.dart';
import 'package:mattermost_flutter/types/database/models/servers/system.dart';

class WithDatabaseArgs {
  final Database database;

  WithDatabaseArgs({required this.database});
}

class CreateServerDatabaseConfig {
  final String dbName;
  final DatabaseType? dbType;
  final String? displayName;
  final String? serverUrl;
  final String? identifier;

  CreateServerDatabaseConfig({required this.dbName, this.dbType, this.displayName, this.serverUrl, this.identifier});
}

class RegisterServerDatabaseArgs {
  final String databaseFilePath;
  final String displayName;
  final String serverUrl;
  final String? identifier;

  RegisterServerDatabaseArgs({required this.databaseFilePath, required this.displayName, required this.serverUrl, this.identifier});
}

class AppDatabase {
  final Database database;
  final AppDataOperator operator;

  AppDatabase({required this.database, required this.operator});
}

class ServerDatabase {
  final Database database;
  final ServerDataOperator operator;

  ServerDatabase({required this.database, required this.operator});
}

class ServerDatabases {
  final Map<String, ServerDatabase?> databases = {};
}

class TransformerArgs {
  final String action;
  final Database database;
  final void Function(Model)? fieldsMapper;
  final String? tableName;
  final RecordPair value;

  TransformerArgs({required this.action, required this.database, this.fieldsMapper, this.tableName, required this.value});
}

class PrepareBaseRecordArgs extends TransformerArgs {
  PrepareBaseRecordArgs({required String action, required Database database, required void Function(Model) fieldsMapper, String? tableName, required RecordPair value})
      : super(action: action, database: database, fieldsMapper: fieldsMapper, tableName: tableName, value: value);
}

class OperationArgs<T extends Model> {
  final String tableName;
  final List<RecordPair>? createRaws;
  final List<RecordPair>? updateRaws;
  final List<T>? deleteRaws;
  final Future<T> Function(TransformerArgs) transformer;

  OperationArgs({required this.tableName, this.createRaws, this.updateRaws, this.deleteRaws, required this.transformer});
}

typedef Models = List<Class<Model>>;

class CreateServerDatabaseArgs {
  final CreateServerDatabaseConfig config;
  final bool? shouldAddToAppDatabase;

  CreateServerDatabaseArgs({required this.config, this.shouldAddToAppDatabase});
}

class HandleReactionsArgs {
  final bool prepareRecordsOnly;
  final List<ReactionsPerPost>? postsReactions;
  final bool? skipSync;

  HandleReactionsArgs({required this.prepareRecordsOnly, this.postsReactions, this.skipSync});
}

class HandleFilesArgs {
  final List<FileInfo>? files;
  final bool prepareRecordsOnly;

  HandleFilesArgs({this.files, required this.prepareRecordsOnly});
}

class HandlePostsArgs {
  final String actionType;
  final List<String>? order;
  final String? previousPostId;
  final List<Post>? posts;
  final bool? prepareRecordsOnly;

  HandlePostsArgs({required this.actionType, this.order, this.previousPostId, this.posts, this.prepareRecordsOnly});
}

class HandleThreadsArgs {
  final List<ThreadWithLastFetchedAt>? threads;
  final bool? prepareRecordsOnly;
  final String? teamId;

  HandleThreadsArgs({this.threads, this.prepareRecordsOnly, this.teamId});
}

class HandleThreadParticipantsArgs {
  final bool prepareRecordsOnly;
  final bool? skipSync;
  final List<ParticipantsPerThread> threadsParticipants;

  HandleThreadParticipantsArgs({required this.prepareRecordsOnly, this.skipSync, required this.threadsParticipants});
}

class HandleThreadInTeamArgs {
  final Map<String, List<Thread>>? threadsMap;
  final bool? prepareRecordsOnly;

  HandleThreadInTeamArgs({this.threadsMap, this.prepareRecordsOnly});
}

class HandleTeamThreadsSyncArgs {
  final List<TeamThreadsSync> data;
  final bool? prepareRecordsOnly;

  HandleTeamThreadsSyncArgs({required this.data, this.prepareRecordsOnly});
}

class SanitizeReactionsArgs {
  final Database database;
  final String postId;
  final List<Reaction> rawReactions;
  final bool? skipSync;

  SanitizeReactionsArgs({required this.database, required this.postId, required this.rawReactions, this.skipSync});
}

class SanitizeThreadParticipantsArgs {
  final Database database;
  final bool? skipSync;
  final String threadId;
  final List<ThreadParticipant> rawParticipants;

  SanitizeThreadParticipantsArgs({required this.database, this.skipSync, required this.threadId, required this.rawParticipants});
}

class ChainPostsArgs {
  final List<String>? order;
  final String previousPostId;
  final List<Post> posts;

  ChainPostsArgs({this.order, required this.previousPostId, required this.posts});
}

class SanitizePostsArgs {
  final List<String> orders;
  final List<Post> posts;

  SanitizePostsArgs({required this.orders, required this.posts});
}

class IdenticalRecordArgs {
  final Model existingRecord;
  final RawValue newValue;
  final String tableName;

  IdenticalRecordArgs({required this.existingRecord, required this.newValue, required this.tableName});
}

class RetrieveRecordsArgs {
  final Database database;
  final String tableName;
  final Clause condition;

  RetrieveRecordsArgs({required this.database, required this.tableName, required this.condition});
}

class ProcessRecordsArgs {
  final List<RawValue> createOrUpdateRawValues;
  final List<RawValue> deleteRawValues;
  final String tableName;
  final String fieldName;
  final String Function(Map<String, dynamic>)? buildKeyRecordBy;
  final bool Function(Map<String, dynamic>, Map<String, dynamic>)? shouldUpdate;

  ProcessRecordsArgs({
    required this.createOrUpdateRawValues,
    required this.deleteRawValues,
    required this.tableName,
    required this.fieldName,
    this.buildKeyRecordBy,
    this.shouldUpdate,
  });
}

class HandleRecordsArgs<T extends Model> {
  final String Function(Map<String, dynamic>)? buildKeyRecordBy;
  final String fieldName;
  final Future<T> Function(TransformerArgs) transformer;
  final List<RawValue> createOrUpdateRawValues;
  final List<RawValue>? deleteRawValues;
  final String tableName;
  final bool prepareRecordsOnly;
  final bool Function(T, RawValue)? shouldUpdate;

  HandleRecordsArgs({
    this.buildKeyRecordBy,
    required this.fieldName,
    required this.transformer,
    required this.createOrUpdateRawValues,
    this.deleteRawValues,
    required this.tableName,
    required this.prepareRecordsOnly,
    this.shouldUpdate,
  });
}

class RangeOfValueArgs {
  final List<RawValue> raws;
  final String fieldName;

  RangeOfValueArgs({required this.raws, required this.fieldName});
}

class RecordPair {
  final Model? record;
  final RawValue raw;

  RecordPair({this.record, required this.raw});
}

class PrepareOnly {
  final bool prepareRecordsOnly;

  PrepareOnly({required this.prepareRecordsOnly});
}

class HandleInfoArgs extends PrepareOnly {
  final List<AppInfo>? info;

  HandleInfoArgs({required bool prepareRecordsOnly, this.info}) : super(prepareRecordsOnly: prepareRecordsOnly);
}

class HandleGlobalArgs extends PrepareOnly {
  final List<IdValue>? globals;

  HandleGlobalArgs({required bool prepareRecordsOnly, this.globals}) : super(prepareRecordsOnly: prepareRecordsOnly);
}

class HandleRoleArgs extends PrepareOnly {
  final List<Role>? roles;

  HandleRoleArgs({required bool prepareRecordsOnly, this.roles}) : super(prepareRecordsOnly: prepareRecordsOnly);
}

class HandleCustomEmojiArgs extends PrepareOnly {
  final List<CustomEmoji>? emojis;

  HandleCustomEmojiArgs({required bool prepareRecordsOnly, this.emojis}) : super(prepareRecordsOnly: prepareRecordsOnly);
}

class HandleSystemArgs extends PrepareOnly {
  final List<IdValue>? systems;

  HandleSystemArgs({required bool prepareRecordsOnly, this.systems}) : super(prepareRecordsOnly: prepareRecordsOnly);
}

class HandleConfigArgs extends PrepareOnly {
  final List<IdValue> configs;
  final List<IdValue> configsToDelete;

  HandleConfigArgs({required bool prepareRecordsOnly, required this.configs, required this.configsToDelete}) : super(prepareRecordsOnly: prepareRecordsOnly);
}

class HandleMyChannelArgs extends PrepareOnly {
  final List<Channel>? channels;
  final List<ChannelMembership>? myChannels;
  final bool? isCRTEnabled;

  HandleMyChannelArgs({required bool prepareRecordsOnly, this.channels, this.myChannels, this.isCRTEnabled}) : super(prepareRecordsOnly: prepareRecordsOnly);
}

class HandleChannelInfoArgs extends PrepareOnly {
  final List<Partial<ChannelInfo>>? channelInfos;

  HandleChannelInfoArgs({required bool prepareRecordsOnly, this.channelInfos}) : super(prepareRecordsOnly: prepareRecordsOnly);
}

class HandleMyChannelSettingsArgs extends PrepareOnly {
  final List<ChannelMembership>? settings;

  HandleMyChannelSettingsArgs({required bool prepareRecordsOnly, this.settings}) : super(prepareRecordsOnly: prepareRecordsOnly);
}

class HandleChannelArgs extends PrepareOnly {
  final List<Channel>? channels;

  HandleChannelArgs({required bool prepareRecordsOnly, this.channels}) : super(prepareRecordsOnly: prepareRecordsOnly);
}

class HandleCategoryArgs extends PrepareOnly {
  final List<Category>? categories;

  HandleCategoryArgs({required bool prepareRecordsOnly, this.categories}) : super(prepareRecordsOnly: prepareRecordsOnly);
}

class HandleGroupArgs extends PrepareOnly {
  final List<Group>? groups;

  HandleGroupArgs({required bool prepareRecordsOnly, this.groups}) : super(prepareRecordsOnly: prepareRecordsOnly);
}

class HandleGroupChannelsForChannelArgs extends PrepareOnly {
  final String channelId;
  final List<Pick<Group, 'id'>>? groups;

  HandleGroupChannelsForChannelArgs({required bool prepareRecordsOnly, required this.channelId, this.groups}) : super(prepareRecordsOnly: prepareRecordsOnly);
}

class HandleGroupMembershipForMemberArgs extends PrepareOnly {
  final String userId;
  final List<Pick<Group, 'id'>>? groups;

  HandleGroupMembershipForMemberArgs({required bool prepareRecordsOnly, required this.userId, this.groups}) : super(prepareRecordsOnly: prepareRecordsOnly);
}

class HandleGroupTeamsForTeamArgs extends PrepareOnly {
  final String teamId;
  final List<Pick<Group, 'id'>>? groups;

  HandleGroupTeamsForTeamArgs({required bool prepareRecordsOnly, required this.teamId, this.groups}) : super(prepareRecordsOnly: prepareRecordsOnly);
}

class HandleCategoryChannelArgs extends PrepareOnly {
  final List<CategoryChannel>? categoryChannels;

  HandleCategoryChannelArgs({required bool prepareRecordsOnly, this.categoryChannels}) : super(prepareRecordsOnly: prepareRecordsOnly);
}

class HandleMyTeamArgs extends PrepareOnly {
  final List<MyTeam>? myTeams;

  HandleMyTeamArgs({required bool prepareRecordsOnly, this.myTeams}) : super(prepareRecordsOnly: prepareRecordsOnly);
}

class HandleTeamSearchHistoryArgs extends PrepareOnly {
  final List<TeamSearchHistory>? teamSearchHistories;

  HandleTeamSearchHistoryArgs({required bool prepareRecordsOnly, this.teamSearchHistories}) : super(prepareRecordsOnly: prepareRecordsOnly);
}

class HandleTeamChannelHistoryArgs extends PrepareOnly {
  final List<TeamChannelHistory>? teamChannelHistories;

  HandleTeamChannelHistoryArgs({required bool prepareRecordsOnly, this.teamChannelHistories}) : super(prepareRecordsOnly: prepareRecordsOnly);
}

class HandleTeamArgs extends PrepareOnly {
  final List<Team>? teams;

  HandleTeamArgs({required bool prepareRecordsOnly, this.teams}) : super(prepareRecordsOnly: prepareRecordsOnly);
}

class HandleChannelMembershipArgs extends PrepareOnly {
  final List<Pick<ChannelMembership, 'userId' | 'channelId' | 'schemeAdmin'>>? channelMemberships;

  HandleChannelMembershipArgs({required bool prepareRecordsOnly, this.channelMemberships}) : super(prepareRecordsOnly: prepareRecordsOnly);
}

class HandleTeamMembershipArgs extends PrepareOnly {
  final List<TeamMembership>? teamMemberships;

  HandleTeamMembershipArgs({required bool prepareRecordsOnly, this.teamMemberships}) : super(prepareRecordsOnly: prepareRecordsOnly);
}

class HandlePreferencesArgs extends PrepareOnly {
  final List<PreferenceType>? preferences;
  final bool? sync;

  HandlePreferencesArgs({required bool prepareRecordsOnly, this.preferences, this.sync}) : super(prepareRecordsOnly: prepareRecordsOnly);
}

class HandleUsersArgs extends PrepareOnly {
  final List<UserProfile>? users;

  HandleUsersArgs({required bool prepareRecordsOnly, this.users}) : super(prepareRecordsOnly: prepareRecordsOnly);
}

class HandleDraftArgs extends PrepareOnly {
  final List<Draft>? drafts;

  HandleDraftArgs({required bool prepareRecordsOnly, this.drafts}) : super(prepareRecordsOnly: prepareRecordsOnly);
}

class LoginArgs {
  final Partial<ClientConfig> config;
  final bool? ldapOnly;
  final Partial<ClientLicense> license;
  final String loginId;
  final String? mfaToken;
  final String password;
  final String serverDisplayName;

  LoginArgs({required this.config, this.ldapOnly, required this.license, required this.loginId, this.mfaToken, required this.password, required this.serverDisplayName});
}

class ServerUrlChangedArgs {
  final System configRecord;
  final System licenseRecord;
  final System selectServerRecord;
  final String serverUrl;

  ServerUrlChangedArgs({required this.configRecord, required this.licenseRecord, required this.selectServerRecord, required this.serverUrl});
}

class GetDatabaseConnectionArgs {
  final String serverUrl;
  final String? connectionName;
  final bool setAsActiveDatabase;

  GetDatabaseConnectionArgs({required this.serverUrl, this.connectionName, required this.setAsActiveDatabase});
}

class ProcessRecordResults<T extends Model> {
  final List<RecordPair> createRaws;
  final List<RecordPair> updateRaws;
  final List<T> deleteRaws;

  ProcessRecordResults({required this.createRaws, required this.updateRaws, required this.deleteRaws});
}
