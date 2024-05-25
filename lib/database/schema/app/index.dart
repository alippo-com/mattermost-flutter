
    // Copyright (c) 2023-present Mattermost, Inc. All Rights Reserved.
    // See LICENSE.txt for license information.

    import 'package:drift/drift.dart';
    import 'package:mattermost_flutter/constants/database.dart';

    const {INFO, GLOBAL, SERVERS} = MM_TABLES.APP;

    @DriftDatabase(tables: [Info, Global, Servers])
    class AppDatabase extends _$AppDatabase {
      AppDatabase(QueryExecutor e) : super(e);

      @override
      int get schemaVersion => 1;
    }

    class Info extends Table {
      TextColumn get buildNumber => text().named('build_number')();
      IntColumn get createdAt => integer().named('created_at')();
      TextColumn get versionNumber => text().named('version_number')();
    }

    class Global extends Table {
      TextColumn get value => text().named('value')();
    }

    class Servers extends Table {
      TextColumn get dbPath => text().named('db_path')();
      TextColumn get displayName => text().named('display_name')();
      TextColumn get identifier => text().named('identifier').indexed()();
      IntColumn get lastActiveAt => integer().named('last_active_at').indexed()();
      TextColumn get url => text().named('url').indexed()();
    }
    