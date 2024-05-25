// Dart (Flutter)
import 'package:mattermost_flutter/constants/database.dart';
import 'package:nozbe_watermelondb/watermelondb.dart';
import 'package:mattermost_flutter/types/database/database.dart' as db_types;
import 'package:mattermost_flutter/models/servers/channel.dart';
import 'package:mattermost_flutter/models/servers/post.dart';
import 'package:mattermost_flutter/models/servers/team.dart';
import 'package:mattermost_flutter/models/servers/user.dart';

const CHANNEL = MM_TABLES.SERVER.CHANNEL;
const POST = MM_TABLES.SERVER.POST;
const TEAM = MM_TABLES.SERVER.TEAM;
const USER = MM_TABLES.SERVER.USER;

class GeneralUtils {

  static Map<String, dynamic>? getValidRecordsForUpdate({required String tableName, required dynamic newValue, required Model existingRecord}) {
    const guardTables = [CHANNEL, POST, TEAM, USER];
    if (guardTables.contains(tableName)) {
      final shouldUpdate = newValue.updateAt == existingRecord.updateAt;

      if (shouldUpdate) {
        return {
          'record': existingRecord,
          'raw': newValue,
        };
      }
    }

    return {
      'record': existingRecord,
      'raw': newValue,
    };
  }

  static List<String> getRangeOfValues({required String fieldName, required List<dynamic> raws}) {
    return raws.fold<List<String>>([], (oneOfs, current) {
      final value = current[fieldName];
      if (value != null && value is String) {
        oneOfs.add(value);
      }
      return oneOfs;
    });
  }

  static List<Map<String, dynamic>> getRawRecordPairs(List<dynamic> raws) {
    return raws.map((raw) {
      return {'raw': raw, 'record': null};
    }).toList();
  }

  static List<dynamic> getUniqueRawsBy({required List<dynamic> raws, required String key}) {
    final map = <dynamic, dynamic>{};
    for (var item in raws) {
      final curItemKey = item[key];
      map[curItemKey] = item;
    }
    return map.values.toList();
  }

  static Future<List<T>> retrieveRecords<T extends Model>({required Database database, required String tableName, required Query condition}) async {
    return await database.collections.get<T>(tableName).query(condition).fetch();
  }
}
