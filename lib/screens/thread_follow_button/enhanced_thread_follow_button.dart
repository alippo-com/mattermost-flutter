import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:mattermost_flutter/database/database.dart';
import 'package:mattermost_flutter/store/ephemeral_store.dart';

class EnhancedThreadFollowButton extends StatefulWidget {
  final String? threadId;

  EnhancedThreadFollowButton({this.threadId});

  @override
  _EnhancedThreadFollowButtonState createState() => _EnhancedThreadFollowButtonState();
}

class _EnhancedThreadFollowButtonState extends State<EnhancedThreadFollowButton> {
  late BehaviorSubject<String> teamIdSubject;
  late BehaviorSubject<bool> isFollowingSubject;

  @override
  void initState() {
    super.initState();

    final thId = widget.threadId ?? EphemeralStore.getCurrentThreadId();
    teamIdSubject = BehaviorSubject<String>.seeded('');
    isFollowingSubject = BehaviorSubject<bool>.seeded(false);

    if (thId.isNotEmpty) {
      observeTeamIdByThreadId(Database(), thId).listen((tId) {
        teamIdSubject.add(tId ?? '');
      });

      observeThreadById(Database(), thId).listen((thread) {
        isFollowingSubject.add(thread?.isFollowing ?? false);
      });
    }
  }

  @override
  void dispose() {
    teamIdSubject.close();
    isFollowingSubject.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: isFollowingSubject,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ThreadFollowButton(isFollowing: snapshot.data!);
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }
}
