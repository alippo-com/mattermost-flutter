// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:watermelondb/watermelondb.dart';
import 'package:mattermost_flutter/helpers/api/preference.dart';
import 'package:mattermost_flutter/queries/servers/post.dart';
import 'package:mattermost_flutter/queries/servers/preference.dart';
import 'package:mattermost_flutter/queries/servers/user.dart';
import 'package:mattermost_flutter/components/header.dart';

import 'package:mattermost_flutter/types/database/models/servers/post.dart';

class HeaderInputProps {
  final bool differentThreadSequence;
  final PostModel post;

  HeaderInputProps({
    required this.differentThreadSequence,
    required this.post,
  });
}

class WithHeaderProps {
  final Database database;
  final HeaderInputProps headerInputProps;

  WithHeaderProps({
    required this.database,
    required this.headerInputProps,
  });

  Observable<Map<String, dynamic>> get props {
    final preferences = queryDisplayNamePreferences(database)
        .observeWithColumns(['value']);
    final author = observePostAuthor(database, headerInputProps.post);
    final enablePostUsernameOverride =
        observeConfigBooleanValue(database, 'EnablePostUsernameOverride');
    final isMilitaryTime = preferences.map((prefs) =>
        getDisplayNamePreferenceAsBool(prefs, 'use_military_time'));
    final teammateNameDisplay = observeTeammateNameDisplay(database);
    final commentCount = queryPostReplies(database,
            headerInputProps.post.rootId ?? headerInputProps.post.id)
        .observeCount();
    final isCustomStatusEnabled =
        observeConfigBooleanValue(database, 'EnableCustomUserStatuses');
    final rootPostAuthor = headerInputProps.differentThreadSequence
        ? observePost(database, headerInputProps.post.rootId).switchMap((root) {
            if (root != null) {
              return observeUser(database, root.userId);
            }

            return Observable.just(null);
          })
        : Observable.just(null);

    return Observable.combineLatest([
      author,
      commentCount,
      enablePostUsernameOverride,
      isCustomStatusEnabled,
      isMilitaryTime,
      rootPostAuthor,
      teammateNameDisplay,
      observeConfigBooleanValue(database, 'HideGuestTags')
    ], (values) {
      return {
        'author': values[0],
        'commentCount': values[1],
        'enablePostUsernameOverride': values[2],
        'isCustomStatusEnabled': values[3],
        'isMilitaryTime': values[4],
        'rootPostAuthor': values[5],
        'teammateNameDisplay': values[6],
        'hideGuestTags': values[7],
      };
    });
  }
}

void main() {
  final database = Database(); // Initialize your database
  final headerInputProps = HeaderInputProps(
    differentThreadSequence: true,
    post: PostModel(), // Initialize your PostModel
  );

  final withHeaderProps = WithHeaderProps(
    database: database,
    headerInputProps: headerInputProps,
  );

  withHeaderProps.props.listen((props) {
    // Use the props in your Header component
    Header(props: props);
  });
}
