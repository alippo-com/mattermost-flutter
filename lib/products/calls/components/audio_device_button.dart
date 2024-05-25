
// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:mattermost_flutter/actions/calls.dart';
import 'package:mattermost_flutter/components/compass_icon.dart';
import 'package:mattermost_flutter/models/call.dart';
import 'package:mattermost_flutter/utils/typography.dart';
import 'package:intl/intl.dart';

class AudioDeviceButton extends StatelessWidget {
  final BoxDecoration pressableStyle;
  final BoxDecoration iconStyle;
  final TextStyle buttonTextStyle;
  final CurrentCall currentCall;

  const AudioDeviceButton({
    required this.pressableStyle,
    required this.iconStyle,
    required this.buttonTextStyle,
    required this.currentCall,
  });

  void toggleSpeakerPhone(BuildContext context) {
    setSpeakerphoneOn(!currentCall.speakerphoneOn);
  }

  @override
  Widget build(BuildContext context) {
    final speakerLabel = Intl.message('SpeakerPhone', name: 'mobile.calls_speaker');
    
    return GestureDetector(
      onTap: () => toggleSpeakerPhone(context),
      child: Container(
        decoration: pressableStyle,
        child: Row(
          children: [
            CompassIcon(
              name: 'volume-high',
              size: 32,
              style: iconStyle,
            ),
            Text(
              speakerLabel,
              style: buttonTextStyle,
            ),
          ],
        ),
      ),
    );
  }
}
