import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:mattermost_flutter/components/bottom_sheet/bottom_sheet_content.dart';
import 'package:mattermost_flutter/context/server.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/utils/server.dart';
import 'package:mattermost_flutter/typings/database/models/app/servers.dart';
import 'package:gorhom_bottom_sheet/gorhom_bottom_sheet.dart';
import 'server_item.dart';

class ServerList extends HookWidget {
  final List<ServersModel> servers;

  ServerList({required this.servers});

  @override
  Widget build(BuildContext context) {
    final intl = useIntl();
    final isTablet = useIsTablet();
    final serverUrl = useServerUrl();
    final theme = useTheme();

    final onAddServer = useCallback(() async {
      addNewServer(theme);
    }, [servers]);

    final renderServer = useCallback((BuildContext context, int index) {
      final t = servers[index];
      return ServerItem(
        highlight: index == 0,
        isActive: t.url == serverUrl,
        server: t,
      );
    }, []);

    final ListType = useMemo(() => isTablet ? ListView : BottomSheetFlatList, [isTablet]);

    return BottomSheetContent(
      buttonIcon: Icons.add,
      buttonText: intl.formatMessage(id: 'servers.create_button', defaultMessage: 'Add a server'),
      onPress: onAddServer,
      showButton: isTablet,
      showTitle: !isTablet,
      testID: 'server_list',
      title: intl.formatMessage(id: 'your.servers', defaultMessage: 'Your servers'),
      child: Container(
        margin: EdgeInsets.only(top: isTablet ? 12 : 0),
        child: ListType.builder(
          itemCount: servers.length,
          itemBuilder: renderServer,
          padding: EdgeInsets.symmetric(vertical: 4),
        ),
      ),
    );
  }
}
