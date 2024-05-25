import 'package:mattermost_flutter/types.dart';
import 'package:watermelondb/watermelondb.dart';

const groupChannel = MMTables.server.groupChannel;

class GroupChannelSchema extends TableSchema {
  @override
  String get name => groupChannel;

  @override
  List<ColumnSchema> get columns => [
        ColumnSchema(name: 'group_id', type: ColumnType.string, isIndexed: true),
        ColumnSchema(name: 'channel_id', type: ColumnType.string, isIndexed: true),
        ColumnSchema(name: 'created_at', type: ColumnType.number),
        ColumnSchema(name: 'updated_at', type: ColumnType.number),
        ColumnSchema(name: 'deleted_at', type: ColumnType.number),
      ];
}