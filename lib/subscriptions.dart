// Converted TypeScript to Dart for Mattermost Flutter project

import 'package:rxdart/rxdart.dart'; // Assuming rxdart is used for Dart equivalent of rxjs

class UnreadMessages {
  final int mentions;
  final bool unread;

  UnreadMessages({required this.mentions, required this.unread});
}

class UnreadSubscription extends UnreadMessages {
  final BehaviorSubject<UnreadMessages>? subscription;

  UnreadSubscription({int mentions, bool unread, this.subscription})
      : super(mentions: mentions, unread: unread);
}