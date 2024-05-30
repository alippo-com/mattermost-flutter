
import 'package:flutter/material.dart';
import 'package:mattermost_flutter/database/database.dart';
import 'package:provider/provider.dart';
import 'option_menus.dart';

class OptionMenusEnhanced extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final database = Provider.of<Database>(context);

    return MultiProvider(
      providers: [
        StreamProvider<bool>(
          create: (_) => observeCanDownloadFiles(database),
          initialData: false,
        ),
        StreamProvider<bool>(
          create: (_) => observeConfigBooleanValue(database, 'EnablePublicLink'),
          initialData: false,
        ),
      ],
      child: OptionMenus(),
    );
  }
}
