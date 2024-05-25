import 'package:flutter_test/flutter_test.dart';
import 'package:mattermost_flutter/database/manager.dart';
import 'package:mattermost_flutter/database/operator/app_data_operator/comparator.dart';
import 'package:mattermost_flutter/database/operator/app_data_operator/transformers.dart';

void main() {
  group('** APP DATA OPERATOR **', () {
    setUpAll(() async {
      await DatabaseManager.init([]);
    });

    test('=> HandleApp: should write to INFO table', () async {
      final appDatabase = DatabaseManager.appDatabase?.database;
      final appOperator = DatabaseManager.appDatabase?.operator;
      expect(appDatabase, isNotNull);
      expect(appOperator, isNotNull);

      var handleRecordsCalled = false;

      appOperator?.handleRecords = (args, methodName) {
        handleRecordsCalled = true;
        expect(methodName, equals('handleInfo'));
        expect(args.fieldName, equals('version_number'));
        expect(args.transformer, equals(transformInfoRecord));
        expect(args.buildKeyRecordBy, equals(buildAppInfoKey));
        expect(args.createOrUpdateRawValues, equals([
          {'build_number': 'build-10x', 'created_at': 1, 'version_number': 'version-10'},
          {'build_number': 'build-11y', 'created_at': 1, 'version_number': 'version-11'},
        ]));
        expect(args.tableName, equals('Info'));
        expect(args.prepareRecordsOnly, isFalse);
      };

      await appOperator?.handleInfo({
        'info': [
          {'build_number': 'build-10x', 'created_at': 1, 'version_number': 'version-10'},
          {'build_number': 'build-11y', 'created_at': 1, 'version_number': 'version-11'},
        ],
        'prepareRecordsOnly': false,
      });

      expect(handleRecordsCalled, isTrue);
    });

    test('=> HandleGlobal: should write to GLOBAL table', () async {
      final appDatabase = DatabaseManager.appDatabase?.database;
      final appOperator = DatabaseManager.appDatabase?.operator;
      expect(appDatabase, isNotNull);
      expect(appOperator, isNotNull);

      var handleRecordsCalled = false;

      appOperator?.handleRecords = (args, methodName) {
        handleRecordsCalled = true;
        expect(methodName, equals('handleGlobal'));
        expect(args.fieldName, equals('id'));
        expect(args.transformer, equals(transformGlobalRecord));
        expect(args.createOrUpdateRawValues, equals([
          {'id': 'global-1-name', 'value': 'global-1-value'}
        ]));
        expect(args.tableName, equals('Global'));
        expect(args.prepareRecordsOnly, isFalse);
      };

      await appOperator?.handleGlobal({
        'globals': [
          {'id': 'global-1-name', 'value': 'global-1-value'}
        ],
        'prepareRecordsOnly': false,
      });

      expect(handleRecordsCalled, isTrue);
    });
  });
}