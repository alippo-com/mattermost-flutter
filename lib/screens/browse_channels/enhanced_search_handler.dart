
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:mattermost_flutter/constants/permissions.dart';
import 'package:mattermost_flutter/queries/channel.dart';
import 'package:mattermost_flutter/queries/role.dart';
import 'package:mattermost_flutter/queries/system.dart';
import 'package:mattermost_flutter/queries/user.dart';
import 'package:mattermost_flutter/utils/role.dart';
import 'package:mattermost_flutter/widgets/search_handler.dart';

class EnhancedSearchHandler extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final database = useDatabase();
    
    final sharedChannelsEnabled = useStream(observeConfigBooleanValue(database, 'ExperimentalSharedChannels'));
    final canShowArchivedChannels = useStream(observeConfigBooleanValue(database, 'ExperimentalViewArchivedChannels'));
    final currentTeamId = useStream(observeCurrentTeamId(database));
    final currentUserId = useStream(observeCurrentUserId(database));
    final joinedChannels = useStream(queryAllMyChannel(database).observe());

    final rolesStream = useMemoizedStream(() async* {
      final userId = await currentUserId.first;
      final user = await observeUser(database, userId).first;
      if (user != null) {
        final roles = user.roles.split(' ');
        yield* queryRolesByNames(database, roles).observeWithColumns(['permissions']);
      } else {
        yield [];
      }
    }, [currentUserId]);

    final canCreateChannels = useStream(useMemoizedStream(() async* {
      final roles = await rolesStream.first;
      yield hasPermission(roles, Permissions.CREATE_PUBLIC_CHANNEL);
    }, [rolesStream]));

    return SearchHandler(
      canCreateChannels: canCreateChannels,
      currentTeamId: currentTeamId,
      joinedChannels: joinedChannels,
      sharedChannelsEnabled: sharedChannelsEnabled,
      canShowArchivedChannels: canShowArchivedChannels,
    );
  }
}
