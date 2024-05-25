import 'package:mattermost_flutter/types.dart';
import 'package:moor/moor.dart';

@DataClassName('GroupChannel')
class GroupChannels extends Table {
  TextColumn get groupId => text().customConstraint('UNIQUE')();
  TextColumn get channelId => text().customConstraint('UNIQUE')();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  IntColumn get deletedAt => integer()();

  @override
  Set<Column> get primaryKey => {groupId, channelId};
}