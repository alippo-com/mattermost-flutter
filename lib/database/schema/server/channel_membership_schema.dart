import 'package:watermelondb/watermelondb.dart';
import '../../types/constants.dart';  // Adjusted path to match Flutter project structure

class ChannelMembershipSchema extends TableSchema {
  @override
  String get name => MM_TABLES.SERVER.CHANNEL_MEMBERSHIP;

  @override
  List<ColumnSchema> get columns => [
        ColumnSchema(name: 'channel_id', type: ColumnType.text, isIndexed: true),
        ColumnSchema(name: 'user_id', type: ColumnType.text, isIndexed: true),
        ColumnSchema(name: 'scheme_admin', type: ColumnType.boolean),
      ];
}
