// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter_test/flutter_test.dart';
import 'package:mattermost_flutter/calls/types/calls.dart';
import 'package:mattermost_flutter/constants.dart';
import 'package:mattermost_flutter/calls/utils.dart';

void main() {
  group('getICEServersConfigs', () {
    test('backwards compatible case, no ICEServersConfigs present', () {
      final config = CallsConfigState(
        pluginEnabled: true,
        ICEServers: ['stun:stun.example.com:3478'],
        ICEServersConfigs: [],
        AllowEnableCalls: true,
        DefaultEnabled: true,
        NeedsTURNCredentials: false,
        lastRetrievedAt: 0,
        skuShortName: License.SKU_SHORT_NAME_PROFESSIONAL,
        MaxCallParticipants: 8,
        EnableRecordings: true,
      );
      final iceConfigs = getICEServersConfigs(config);

      expect(iceConfigs, [
        ICEServerConfig(urls: ['stun:stun.example.com:3478']),
      ]);
    });

    test('ICEServersConfigs set', () {
      final config = CallsConfigState(
        pluginEnabled: true,
        ICEServersConfigs: [
          ICEServerConfig(urls: ['stun:stun.example.com:3478']),
          ICEServerConfig(urls: ['turn:turn.example.com:3478']),
        ],
        AllowEnableCalls: true,
        DefaultEnabled: true,
        NeedsTURNCredentials: false,
        lastRetrievedAt: 0,
        skuShortName: License.SKU_SHORT_NAME_PROFESSIONAL,
        MaxCallParticipants: 8,
        EnableRecordings: true,
      );
      final iceConfigs = getICEServersConfigs(config);

      expect(iceConfigs, [
        ICEServerConfig(urls: ['stun:stun.example.com:3478']),
        ICEServerConfig(urls: ['turn:turn.example.com:3478']),
      ]);
    });

    test('Both ICEServers and ICEServersConfigs set', () {
      final config = CallsConfigState(
        pluginEnabled: true,
        ICEServers: ['stun:stuna.example.com:3478'],
        ICEServersConfigs: [
          ICEServerConfig(urls: ['stun:stunb.example.com:3478']),
          ICEServerConfig(urls: ['turn:turn.example.com:3478']),
        ],
        AllowEnableCalls: true,
        DefaultEnabled: true,
        NeedsTURNCredentials: false,
        lastRetrievedAt: 0,
        skuShortName: License.SKU_SHORT_NAME_PROFESSIONAL,
        MaxCallParticipants: 8,
        EnableRecordings: true,
      );
      final iceConfigs = getICEServersConfigs(config);

      expect(iceConfigs, [
        ICEServerConfig(urls: ['stun:stunb.example.com:3478']),
        ICEServerConfig(urls: ['turn:turn.example.com:3478']),
      ]);
    });
  });
}
