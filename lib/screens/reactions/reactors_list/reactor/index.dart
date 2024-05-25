// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:mattermost_flutter/types/database/models/servers/reaction.dart';
import 'package:mattermost_flutter/types/database/models/servers/post.dart';
import 'package:mattermost_flutter/types/database/models/servers/user.dart';
import 'package:mattermost_flutter/actions/remote/user.dart';
import 'package:mattermost_flutter/actions/remote/post.dart';
import 'package:mattermost_flutter/screens/reactions/reactors_list/reactor.dart';

class ReactorList extends StatefulWidget {
  final ReactionModel reaction;

  ReactorList({required this.reaction});

  @override
  _ReactorListState createState() => _ReactorListState();
}

class _ReactorListState extends State<ReactorList> {
  late Future<String?> channelId;
  late Future<User?> user;

  @override
  void initState() {
    super.initState();
    channelId = _fetchChannelId(widget.reaction.postId);
    user = _fetchUser(widget.reaction.userId);
  }

  Future<String?> _fetchChannelId(String postId) async {
    final post = await fetchPostById(postId);
    return post?.channelId;
  }

  Future<User?> _fetchUser(String userId) async {
    return await fetchUserById(userId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.wait([channelId, user]),
      builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          final channelId = snapshot.data?[0] as String?;
          final user = snapshot.data?[1] as User?;
          
          if (channelId != null && user != null) {
            return Reactor(
              reaction: widget.reaction,
              channelId: channelId,
              user: user,
            );
          } else {
            return Text('Unable to fetch data');
          }
        }
      },
    );
  }
}
