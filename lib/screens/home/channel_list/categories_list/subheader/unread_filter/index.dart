
import 'package:flutter/material.dart';
import 'package:watermelon_db/watermelon_db.dart';
import 'package:mattermost_flutter/screens/home/channel_list/categories_list/subheader/unread_filter/unread_filter.dart';

class EnhancedUnreadFilter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final database = DatabaseProvider.of(context);

    return StreamBuilder<bool>(
      stream: observeOnlyUnreads(database),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }

        return UnreadFilter(
          onlyUnreads: snapshot.data!,
        );
      },
    );
  }
}
