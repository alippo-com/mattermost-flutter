// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:mattermost_flutter/utils/mention_settings.dart';
import 'package:mattermost_flutter/types/user_model.dart';
import 'package:test/test.dart';

void main() {
  group('getMentionProps', () {
    test('Should have correct return type when input is empty', () {
      final mentionProps = getMentionProps(UserModel(notifyProps: UserNotifyProps()));

      expect(mentionProps, equals({
        'mentionKeywords': [],
        'usernameMention': false,
        'channel': false,
        'first_name': false,
        'comments': '',
        'notifyProps': UserNotifyProps(),
      }));
    });

    test('Should have correct return type for when channel, first_name, currentUser.username are provided', () {
      final mentionProps = getMentionProps(UserModel(
        username: 'testUser',
        notifyProps: UserNotifyProps(
          comments: 'any',
          channel: 'true',
          first_name: 'true',
          mention_keys: 'testUser',
        ),
      ));

      expect(mentionProps['mentionKeywords'], equals([]));
      expect(mentionProps['usernameMention'], equals(true));
      expect(mentionProps['channel'], equals(true));
      expect(mentionProps['first_name'], equals(true));
    });

    test('Should have correct return type for mention_keys input', () {
      final mentionProps = getMentionProps(UserModel(
        username: 'testUser',
        notifyProps: UserNotifyProps(
          mention_keys: 'testUser,testUser2,testKey1,testKey2',
        ),
      ));

      expect(mentionProps['mentionKeywords'], hasLength(3));
      expect(mentionProps['mentionKeywords'], equals(['testUser2', 'testKey1', 'testKey2']));
    });
  });

  group('canSaveSettings', () {
    test('Should return true when mentionKeywords have changed', () {
      final canSaveSettingParams = CanSaveSettings(
        mentionKeywords: ['test1', 'test2'],
        mentionProps: {
          'mentionKeywords': ['test1', 'test2', 'test3'],
        },
      );

      expect(canSaveSettings(canSaveSettingParams), equals(true));
    });

    test('Should return false when mentionKeywords have not changed', () {
      final canSaveSettingParams = CanSaveSettings(
        mentionKeywords: ['test1', 'test2'],
        mentionProps: {
          'mentionKeywords': ['test2', 'test1'],
        },
      );

      expect(canSaveSettings(canSaveSettingParams), equals(false));
    });

    test('Should return true when only userName has changed', () {
      final canSaveSettingParams = CanSaveSettings(
        channelMentionOn: true,
        replyNotificationType: 'any',
        firstNameMentionOn: true,
        usernameMentionOn: true,
        mentionKeywords: ['test1', 'test2'],
        mentionProps: {
          'channel': true,
          'comments': 'any',
          'first_name': true,
          'usernameMention': false,
          'mentionKeywords': ['test1', 'test2'],
          'notifyProps': UserNotifyProps(),
        },
      );

      expect(canSaveSettings(canSaveSettingParams), equals(true));
    });
  });

  group('getUniqueKeywordsFromInput', () {
    test('Should return empty if input is empty and keywords are empty', () {
      expect(getUniqueKeywordsFromInput('', []), equals([]));
    });

    test('Should return same keywords if input is empty', () {
      expect(getUniqueKeywordsFromInput('', ['test1', 'test2']), equals(['test1', 'test2']));
    });

    test('Should return same input if keywords are empty', () {
      expect(getUniqueKeywordsFromInput('test1', []), equals(['test1']));
    });

    test('Should filter out commas from input', () {
      expect(getUniqueKeywordsFromInput('tes,,t1,', []), equals(['test1']));
      expect(getUniqueKeywordsFromInput(',,    ,', ['test1']), equals(['test1']));
    });

    test('Should filter out spaces from input', () {
      expect(getUniqueKeywordsFromInput('t     es t      1', []), equals(['test1']));
    });

    test('Should filter out duplicate keywords from input', () {
      expect(getUniqueKeywordsFromInput('te,s   t1', ['test1', 'test2']), equals(['test1', 'test2']));
    });
  });
}
