import 'package:watermelondb/watermelondb.dart';
import 'package:mattermost_flutter/constants/database.dart';
import 'package:mattermost_flutter/database/manager.dart';
import 'package:mattermost_flutter/types/models/app/info.dart';

Future<InfoModel?> getLastInstalledVersion() async {
  try {
    final database = DatabaseManager.getAppDatabaseAndOperator().database;
    final infos = await database.get<InfoModel>(MM_TABLES.APP.INFO).query(
      Q.sortBy('created_at', Q.desc),
      Q.take(1),
    ).fetch();
    return infos.isNotEmpty ? infos[0] : null;
  } catch (_) {
    return null;
  }
}
