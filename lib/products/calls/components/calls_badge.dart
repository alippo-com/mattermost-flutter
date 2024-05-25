// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:mattermost_flutter/components/compass_icon.dart';
import 'package:mattermost_flutter/components/formatted_text.dart';
import 'package:mattermost_flutter/components/loading.dart';
import 'package:mattermost_flutter/utils/typography.dart';

enum CallsBadgeType { Waiting, Rec, Host }

class CallsBadge extends StatelessWidget {
  final CallsBadgeType type;

  const CallsBadge({Key? key, required this.type}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isLoading = type == CallsBadgeType.Waiting;
    final isRec = type == CallsBadgeType.Rec;
    final isParticipant = !(isLoading || isRec);

    final text = isLoading || isRec
        ? FormattedText(
            id: 'mobile.calls_rec',
            defaultMessage: 'rec',
            style: TextStyle(
              color: Colors.white,
              textBaseline: TextBaseline.alphabetic,
            ).merge(typography('Body', 75, 'SemiBold')),
          )
        : FormattedText(
            id: 'mobile.calls_host',
            defaultMessage: 'host',
            style: TextStyle(
              color: Colors.white,
              textBaseline: TextBaseline.alphabetic,
            ).merge(typography('Body', 75, 'SemiBold')),
          );

    final containerStyles = [
      styles.container,
      if (isLoading) styles.loading,
      if (isRec) styles.recording,
      if (isParticipant) styles.participant,
    ];

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isLoading) Loading(),
          if (isRec)
            CompassIcon(
              name: 'record-circle-outline',
              size: 12,
              color: Colors.white,
            ),
          text,
        ],
      ),
    );
  }
}

class styles {
  static final container = BoxDecoration(
    borderRadius: BorderRadius.circular(4),
  );

  static final loading = BoxDecoration(
    color: Color.fromRGBO(255, 255, 255, 0.16),
    borderRadius: BorderRadius.circular(4),
  );

  static final recording = BoxDecoration(
    color: Color(0xFFD24B4E),
    borderRadius: BorderRadius.circular(4),
  );

  static final participant = BoxDecoration(
    color: Color.fromRGBO(255, 255, 255, 0.16),
    borderRadius: BorderRadius.circular(4),
  );
}
