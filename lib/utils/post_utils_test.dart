// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:mattermost_flutter/types/utils.dart'; // Adjusted import path

void main() {
  group('post utils', () {
    var testCases = [
      ['@here where is Jessica Hyde', true],
      ['@all where is Jessica Hyde', true],
      ['@channel where is Jessica Hyde', true],

      ['where is Jessica Hyde @here', true],
      ['where is Jessica Hyde @all', true],
      ['where is Jessica Hyde @channel', true],

      ['where is Jessica @here Hyde', true],
      ['where is Jessica @all Hyde', true],
      ['where is Jessica @channel Hyde', true],

      ['where is Jessica Hyde
@here', true],
      ['where is Jessica Hyde
@all', true],
      ['where is Jessica Hyde
@channel', true],

      ['where is Jessica
@here Hyde', true],
      ['where is Jessica
@all Hyde', true],
      ['where is Jessica
@channel Hyde', true],

      ['where is Jessica Hyde @her', false],
      ['where is Jessica Hyde @al', false],
      ['where is Jessica Hyde @chann', false],

      ['where is Jessica Hyde@here', false],
      ['where is Jessica Hyde@all', false],
      ['where is Jessica Hyde@channel', false],

      ['where is Jessica @hereHyde', false],
      ['where is Jessica @allHyde', false],
      ['where is Jessica @channelHyde', false],

      ['@herewhere is Jessica Hyde@here', false],
      ['@allwhere is Jessica Hyde@all', false],
      ['@channelwhere is Jessica Hyde@channel', false],

      ['where is Jessica Hyde here', false],
      ['where is Jessica Hyde all', false],
      ['where is Jessica Hyde channel', false],

      ['where is Jessica Hyde', false],
    ];

    for (var testCase in testCases) {
      test('hasSpecialMentions: ${testCase[0]} => ${testCase[1]}', () {
        expect(Utils.hasSpecialMentions(testCase[0]), testCase[1]);
      });
    }
  });
}