import 'package:mattermost_flutter/constants/database.dart';
import 'package:mattermost_flutter/database/operator/server_data_operator/comparators.dart';
import 'package:mattermost_flutter/helpers/api/preference.dart';
import 'package:mattermost_flutter/utils/log.dart';
import 'package:mattermost_flutter/types/database/models/servers/preference.dart';

const PREFERENCE = MM_TABLES.SERVER.PREFERENCE;
const USER = MM_TABLES.SERVER.USER;

abstract class UserHandlerMix {
  Future<List<PreferenceModel>> handlePreferences({required HandlePreferencesArgs preferencesArgs});
  Future<List<UserModel>> handleUsers({required HandleUsersArgs usersArgs});
}

class UserHandler<TBase extends ServerDataOperatorBase> extends TBase implements UserHandlerMix {
  @override
  Future<List<PreferenceModel>> handlePreferences({required HandlePreferencesArgs preferencesArgs}) async {
    List<PreferenceModel> records = [];

    if (preferencesArgs.preferences == null || preferencesArgs.preferences!.isEmpty) {
      logWarning('An empty or undefined "preferences" array has been passed to the handlePreferences method');
      return records;
    }

    List<PreferenceModel> filtered = filterPreferences(preferencesArgs.preferences!);

    List<PreferenceModel> deleteValues = [];
    List<PreferenceModel> stored = await this.database.get(PREFERENCE).query().fetch();
    Map<String, PreferenceModel> storedPreferencesMap = {for (var p in stored) '${p.category}-${p.name}': p};
    if (preferencesArgs.sync) {
      Map<String, PreferenceModel> rawPreferencesMap = {for (var p in filtered) '${p.category}-${p.name}': p};
      for (var pref in stored) {
        if (!rawPreferencesMap.containsKey('${pref.category}-${pref.name}')) {
          pref.prepareDestroyPermanently();
          deleteValues.add(pref);
        }
      }
    }

    List<PreferenceModel> createOrUpdateRawValues = filtered.where((p) {
      String id = '${p.category}-${p.name}';
      PreferenceModel? exist = storedPreferencesMap[id];
      if (exist == null || p.category != exist.category || p.name != exist.name || p.value != exist.value) {
        return true;
      }
      return false;
    }).toList();

    if (createOrUpdateRawValues.isEmpty && deleteValues.isEmpty) {
      return records;
    }

    if (createOrUpdateRawValues.isNotEmpty) {
      List<PreferenceModel> createOrUpdate = await this.handleRecords(
        fieldName: 'user_id',
        buildKeyRecordBy: buildPreferenceKey,
        transformer: transformPreferenceRecord,
        prepareRecordsOnly: true,
        createOrUpdateRawValues: createOrUpdateRawValues,
        tableName: PREFERENCE,
      );
      records.addAll(createOrUpdate);
    }

    if (deleteValues.isNotEmpty) {
      records.addAll(deleteValues);
    }

    if (records.isNotEmpty && !preferencesArgs.prepareRecordsOnly) {
      await this.batchRecords(records, 'handlePreferences');
    }

    return records;
  }

  @override
  Future<List<UserModel>> handleUsers({required HandleUsersArgs usersArgs}) async {
    if (usersArgs.users == null || usersArgs.users!.isEmpty) {
      logWarning('An empty or undefined "users" array has been passed to the handleUsers method');
      return [];
    }

    List<UserModel> createOrUpdateRawValues = getUniqueRawsBy(raws: usersArgs.users!, key: 'id');

    return this.handleRecords(
      fieldName: 'id',
      transformer: transformUserRecord,
      createOrUpdateRawValues: createOrUpdateRawValues,
      tableName: USER,
      prepareRecordsOnly: usersArgs.prepareRecordsOnly,
      shouldUpdate: shouldUpdateUserRecord,
    );
  }
}
