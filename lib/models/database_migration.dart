import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:mattermost_flutter/models/types.dart';

class DatabaseMigration {
  final Database db;

  DatabaseMigration(this.db);

  Future<void> migrate() async {
    await db.transaction((txn) async {
      var batch = txn.batch();

      // Migration to version 3
      await _addColumns(batch, POST_TABLE, [
        ColumnSpec(name: 'message_source', type: 'TEXT'),
      ]);

      // Migration to version 2
      await _addColumns(batch, CHANNEL_INFO_TABLE, [
        ColumnSpec(name: 'files_count', type: 'INTEGER'),
      ]);
      await _addColumns(batch, DRAFT_TABLE, [
        ColumnSpec(name: 'metadata', type: 'TEXT', isOptional: true),
      ]);

      await batch.commit();
    });
  }

  Future<void> _addColumns(Batch batch, String table, List<ColumnSpec> columns) async {
    for (var column in columns) {
      String columnType = column.isOptional ? ' NULL' : ' NOT NULL';
      batch.execute('ALTER TABLE $table ADD COLUMN ${column.name} ${column.type}$columnType');
    }
  }
}

class ColumnSpec {
  final String name;
  final String type;
  final bool isOptional;

  ColumnSpec({required this.name, required this.type, this.isOptional = false});
}