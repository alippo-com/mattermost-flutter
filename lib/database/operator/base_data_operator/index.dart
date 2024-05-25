
  @override
  Future<List<T>> prepareRecords<T extends Model>({
    required String tableName,
    required List<RawValue> createRaws,
    required List<RawValue> updateRaws,
    required List<RawValue> deleteRaws,
    required TransformerArgs transformer,
  }) async {
    if (database == null) {
      logWarning('Database not defined in prepareRecords');
      return [];
    }

    var preparedRecords = <Future<T>>[];

    if (createRaws.isNotEmpty) {
      final recordPromises = createRaws.map((createRecord) {
        return transformer(
          database: database,
          tableName: tableName,
          value: createRecord,
          action: OperationType.CREATE,
        );
      }).toList();

      preparedRecords = preparedRecords..addAll(recordPromises);
    }

    if (updateRaws.isNotEmpty) {
      final recordPromises = updateRaws.map((updateRecord) {
        return transformer(
          database: database,
          tableName: tableName,
          value: updateRecord,
          action: OperationType.UPDATE,
        );
      }).toList();

      preparedRecords = preparedRecords..addAll(recordPromises);
    }

    final results = await Future.wait(preparedRecords);

    if (deleteRaws.isNotEmpty) {
      deleteRaws.forEach((deleteRecord) {
        results.add(deleteRecord.prepareDestroyPermanently());
      });
    }

    return results;
  }

  @override
  Future<void> batchRecords(List<Model> models, String description) async {
    try {
      if (models.isNotEmpty) {
        await database.write((writer) async {
          await writer.batch(models);
        }, description);
      }
    } catch (e) {
      logWarning('batchRecords error ', description, e);
    }
  }

  @override
  Future<List<T>> handleRecords<T extends Model>({
    required HandleRecordsArgs<T> handleRecordsArgs,
    required String description,
  }) async {
    if (handleRecordsArgs.createOrUpdateRawValues.isEmpty) {
      logWarning('An empty "rawValues" array has been passed to the handleRecords method for tableName \${handleRecordsArgs.tableName}');
      return [];
    }

    final results = await processRecords<T>(
      createOrUpdateRawValues: handleRecordsArgs.createOrUpdateRawValues,
      deleteRawValues: handleRecordsArgs.deleteRawValues,
      tableName: handleRecordsArgs.tableName,
      fieldName: handleRecordsArgs.fieldName,
      buildKeyRecordBy: handleRecordsArgs.buildKeyRecordBy,
    );

    final models = await prepareRecords<T>(
      tableName: handleRecordsArgs.tableName,
      createRaws: results.createRaws,
      updateRaws: results.updateRaws,
      deleteRaws: results.deleteRaws,
      transformer: handleRecordsArgs.transformer,
    );

    if (!handleRecordsArgs.prepareRecordsOnly && models.isNotEmpty) {
      await batchRecords(models, description);
    }

    return models;
  }
}
