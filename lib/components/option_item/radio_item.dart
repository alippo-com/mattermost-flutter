// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:mattermost_flutter/components/compass_icon.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/utils/theme.dart';

const double RADIO_SIZE = 24.0;

class RadioItem extends StatelessWidget {
  final bool selected;
  final bool? checkedBody;
  final String? testID;

  RadioItem({
    required this.selected,
    this.checkedBody,
    this.testID,
  });

  @override
  Widget build(BuildContext context) {
    final theme = useTheme(context);

    BoxDecoration ringDecoration = BoxDecoration(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(RADIO_SIZE / 2),
      border: Border.all(
        color: selected ? theme.buttonBg : changeOpacity(theme.centerChannelColor, 0.56),
        width: 2.0,
      ),
    );

    Widget getBody() {
      if (checkedBody == true) {
        return Container(
          decoration: BoxDecoration(
            color: theme.buttonBg,
          ),
          child: CompassIcon(
            color: theme.buttonColor,
            name: 'check',
            size: RADIO_SIZE / 1.5,
          ),
        );
      } else {
        return Container(
          width: RADIO_SIZE / 2,
          height: RADIO_SIZE / 2,
          decoration: BoxDecoration(
            color: theme.buttonBg,
            borderRadius: BorderRadius.circular(RADIO_SIZE / 2),
          ),
        );
      }
    }

    return Container(
      decoration: ringDecoration,
      margin: EdgeInsets.only(right: 16.0),
      alignment: Alignment.center,
      child: selected ? getBody() : null,
    );
  }
}
