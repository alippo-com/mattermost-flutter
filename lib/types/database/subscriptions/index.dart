// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

// Importing necessary packages, assuming a Dart equivalent of rxjs exists or is not needed directly.
// import 'package:rxjs/rxjs.dart'; // Uncomment and edit if rxjs is needed in Dart.

class UnreadMessages {
  int mentions;
  bool unread;

  UnreadMessages({this.mentions, this.unread});
}

class UnreadSubscription extends UnreadMessages {
  var subscription;  // Type should be defined if Dart equivalent of Subscription is used.

  UnreadSubscription({int mentions, bool unread, this.subscription})
      : super(mentions: mentions, unread: unread);
}