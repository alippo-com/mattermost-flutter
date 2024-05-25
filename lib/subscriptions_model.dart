// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:rxdart/rxdart.dart';

class UnreadMessages {
  final int mentions;
  final bool unread;
  UnreadMessages({required this.mentions, required this.unread});
}

class UnreadSubscription extends UnreadMessages {
  BehaviorSubject<UnreadMessages>? subscription;

  UnreadSubscription({int mentions, bool unread, this.subscription}) : super(mentions: mentions, unread: unread);
}
