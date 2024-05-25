
// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:mattermost_flutter/constants/permissions.dart';
import 'package:mattermost_flutter/data/database.dart';
import 'package:mattermost_flutter/queries/system.dart';
import 'package:mattermost_flutter/queries/user.dart';
import 'package:mattermost_flutter/queries/app/servers.dart';
import 'package:mattermost_flutter/utils/server.dart';
import 'package:mattermost_flutter/utils/user.dart';
import 'package:mattermost_flutter/actions/local/systems.dart';
import 'package:mattermost_flutter/context/server.dart';
import 'package:mattermost_flutter/types/database/database.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // For localization

class ServerVersion extends StatefulWidget {
  final bool isAdmin;
  final int lastChecked;
  final String? version;

  ServerVersion({required this.isAdmin, required this.lastChecked, this.version});

  @override
  _ServerVersionState createState() => _ServerVersionState();
}

class _ServerVersionState extends State<ServerVersion> {
  static const int VALIDATE_INTERVAL = 24 * 60 * 60 * 1000; // 24 hours

  @override
  void initState() {
    super.initState();
    final serverUrl = context.read<ServerUrlProvider>().serverUrl;
    final intl = AppLocalizations.of(context)!;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final serverVersion = widget.version ?? '';
      final shouldValidate = (DateTime.now().millisecondsSinceEpoch - widget.lastChecked) >= VALIDATE_INTERVAL || widget.lastChecked == 0;

      if (serverVersion.isNotEmpty && shouldValidate && !isSupportedServer(serverVersion)) {
        handleUnsupportedServer(serverUrl, widget.isAdmin, intl);
      }
    });
  }

  Future<void> handleUnsupportedServer(String serverUrl, bool isAdmin, AppLocalizations intl) async {
    final serverModel = await getServer(serverUrl);
    unsupportedServer(serverModel?.displayName ?? '', isAdmin, intl);
    setLastServerVersionCheck(serverUrl);
  }

  @override
  Widget build(BuildContext context) {
    return Container(); // Equivalent to returning null in React
  }
}

class ServerVersionProvider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final database = Provider.of<Database>(context);

    return StreamProvider<ServerVersion>(
      create: (_) => Rx.combineLatest3(
        observeLastServerVersionCheck(database),
        observeConfigValue(database, 'Version'),
        observeCurrentUser(database).pipe(
          map((user) => isSystemAdmin(user?.roles ?? '')),
          distinctUntilChanged(),
        ),
        (lastChecked, version, isAdmin) => ServerVersion(
          lastChecked: lastChecked,
          version: version,
          isAdmin: isAdmin,
        ),
      ),
      initialData: ServerVersion(isAdmin: false, lastChecked: 0),
      child: Consumer<ServerVersion>(
        builder: (context, serverVersion, child) {
          return ServerVersion(
            isAdmin: serverVersion.isAdmin,
            lastChecked: serverVersion.lastChecked,
            version: serverVersion.version,
          );
        },
      ),
    );
  }
}
