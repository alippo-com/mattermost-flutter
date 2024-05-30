
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:mattermost_flutter/constants/general.dart';
import 'package:mattermost_flutter/constants/permissions.dart';
import 'package:mattermost_flutter/queries/servers/channel.dart';
import 'package:mattermost_flutter/queries/servers/drafts.dart';
import 'package:mattermost_flutter/queries/servers/user.dart';
import 'package:mattermost_flutter/components/post_draft.dart';

class PostDraftProvider extends StatelessWidget {
  final String channelId;
  final bool? channelIsArchived;
  final String? rootId;

  PostDraftProvider({
    required this.channelId,
    this.channelIsArchived,
    this.rootId,
  });

  @override
  Widget build(BuildContext context) {
    final database = Provider.of<Database>(context);

    final channelIdStream = channelId.isNotEmpty
        ? BehaviorSubject<String>.seeded(channelId)
        : observeCurrentChannelId(database);

    final draftStream = channelIdStream.switchMap((cId) => queryDraft(database, cId, rootId ?? '').observeWithColumns(['message', 'files', 'metadata']).switchMap(observeFirstDraft));

    final filesStream = draftStream.switchMap((d) => BehaviorSubject<List<File>?>.seeded(d?.files));
    final messageStream = draftStream.switchMap((d) => BehaviorSubject<String?>.seeded(d?.message));

    final currentUserStream = observeCurrentUser(database);

    final channelStream = channelIdStream.switchMap((id) => observeChannel(database, id));

    final canPostStream = Rx.combineLatest2(channelStream, currentUserStream, (c, u) => c != null && u != null ? observePermissionForChannel(database, c, u, Permissions.CREATE_POST, true) : BehaviorSubject<bool>.seeded(true));

    final channelIsArchivedStream = channelStream.switchMap((c) => channelIsArchived != null ? BehaviorSubject<bool>.seeded(true) : BehaviorSubject<bool>.seeded(c?.deleteAt != 0));

    final experimentalTownSquareIsReadOnlyStream = observeConfigBooleanValue(database, 'ExperimentalTownSquareIsReadOnly');
    final channelIsReadOnlyStream = Rx.combineLatest3(currentUserStream, channelStream, experimentalTownSquareIsReadOnlyStream, (u, c, readOnly) => BehaviorSubject<bool>.seeded(c?.name == General.DEFAULT_CHANNEL && !isSystemAdmin(u?.roles ?? '') && readOnly));

    final deactivatedChannelStream = Rx.combineLatest2(currentUserStream, channelStream, (u, c) {
      if (u == null || c == null) {
        return BehaviorSubject<bool>.seeded(false);
      }
      if (c.type != General.DM_CHANNEL) {
        return BehaviorSubject<bool>.seeded(false);
      }
      final teammateId = getUserIdFromChannelName(u.id, c.name);
      if (teammateId != null) {
        return observeUser(database, teammateId).switchMap((u2) => BehaviorSubject<bool>.seeded(u2?.deleteAt != null));
      }
      return BehaviorSubject<bool>.seeded(true);
    });

    return StreamProvider.value(
      value: canPostStream,
      initialData: true,
      child: StreamProvider.value(
        value: channelIsArchivedStream,
        initialData: false,
        child: StreamProvider.value(
          value: channelIsReadOnlyStream,
          initialData: false,
          child: StreamProvider.value(
            value: deactivatedChannelStream,
            initialData: false,
            child: StreamProvider.value(
              value: filesStream,
              initialData: null,
              child: StreamProvider.value(
                value: messageStream,
                initialData: null,
                child: PostDraft(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
