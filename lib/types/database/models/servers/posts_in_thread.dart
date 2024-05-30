// See LICENSE.txt for license information.

import 'package:sqflite/sqflite.dart';
import 'package:mattermost_flutter/types/post.dart';
import 'package:mattermost_flutter/types/associations.dart';

class PostsInThreadModel {
  static const String table = 'PostsInThread';

  static final Associations associations = Associations();

  final String rootId;
  final int earliest;
  final int latest;
  final PostModel post;

  PostsInThreadModel({
    required this.rootId,
    required this.earliest,
    required this.latest,
    required this.post,
  });

  factory PostsInThreadModel.fromMap(Map<String, dynamic> map) {
    return PostsInThreadModel(
      rootId: map['rootId'],
      earliest: map['earliest'],
      latest: map['latest'],
      post: PostModel.fromMap(map['post']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'rootId': rootId,
      'earliest': earliest,
      'latest': latest,
      'post': post.toMap(),
    };
  }
}
