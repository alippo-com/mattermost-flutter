import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mattermost_flutter/types/database/manager.dart';
import 'package:mattermost_flutter/types/database/models/app/servers.dart';
import 'package:mattermost_flutter/context/device.dart';
import 'package:mattermost_flutter/context/server.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/context/user_locale.dart';
import 'package:mattermost_flutter/database/subscription/servers.dart';

class State {
  final Database database;
  final String serverUrl;
  final String serverDisplayName;

  State({required this.database, required this.serverUrl, required this.serverDisplayName});
}

class ServerDatabaseComponent<T> extends StatefulWidget {
  final Widget Function(BuildContext context, T props) builder;
  final T props;

  ServerDatabaseComponent({required this.builder, required this.props});

  @override
  _ServerDatabaseComponentState<T> createState() => _ServerDatabaseComponentState<T>();
}

class _ServerDatabaseComponentState<T> extends State<ServerDatabaseComponent<T>> {
  State? _state;

  @override
  void initState() {
    super.initState();
    subscribeActiveServers(_observer);
  }

  void _observer(List<ServersModel> servers) {
    final server = servers.isNotEmpty
        ? servers.reduce((a, b) => b.lastActiveAt > a.lastActiveAt ? b : a)
        : null;

    if (server != null) {
      final database = DatabaseManager.serverDatabases[server.url]?.database;

      if (database != null) {
        setState(() {
          _state = State(
            database: database,
            serverUrl: server.url,
            serverDisplayName: server.displayName,
          );
        });
      }
    } else {
      setState(() {
        _state = null;
      });
    }
  }

  @override
  void dispose() {
    unsubscribeActiveServers(_observer);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_state?.database == null) {
      return Container();
    }

    return Provider.value(
      value: _state!.database,
      child: DeviceInfoProvider(
        child: UserLocaleProvider(
          database: _state!.database,
          child: ServerProvider(
            server: Server(displayName: _state!.serverDisplayName, url: _state!.serverUrl),
            child: ThemeProvider(
              database: _state!.database,
              child: widget.builder(context, widget.props),
            ),
          ),
        ),
      ),
    );
  }
}

Widget withServerDatabase<T>(Widget Function(BuildContext context, T props) builder, T props) {
  return ServerDatabaseComponent<T>(builder: builder, props: props);
}
