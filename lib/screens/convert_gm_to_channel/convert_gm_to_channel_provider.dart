import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:mattermost_flutter/queries/servers/user.dart';
import 'package:mattermost_flutter/screens/convert_gm_to_channel/convert_gm_to_channel_form.dart';
import 'package:mattermost_flutter/types/database/database.dart';

class ConvertGMToChannelProvider extends StatelessWidget {
  final Widget child;

  ConvertGMToChannelProvider({required this.child});

  @override
  Widget build(BuildContext context) {
    final database = Provider.of<Database>(context);

    final localeStream = observeCurrentUser(database)
        .switchMap((user) => Stream.value(user?.locale))
        .distinct();

    final teammateNameDisplayStream = observeTeammateNameDisplay(database);

    return MultiProvider(
      providers: [
        StreamProvider<String?>.value(value: localeStream, initialData: null),
        StreamProvider<String?>.value(value: teammateNameDisplayStream, initialData: null),
      ],
      child: child,
    );
  }
}
