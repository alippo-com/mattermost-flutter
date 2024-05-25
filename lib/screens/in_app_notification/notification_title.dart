// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';

class NotificationTitleProps {
  final String channelName;

  NotificationTitleProps({required this.channelName});
}

class NotificationTitle extends StatelessWidget {
  final NotificationTitleProps props;

  const NotificationTitle({Key? key, required this.props}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      props.channelName,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontFamily: 'OpenSans-SemiBold',
      ),
    );
  }
}
