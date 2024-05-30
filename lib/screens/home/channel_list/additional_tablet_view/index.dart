import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mattermost_flutter/components/additional_tablet_view.dart';

final currentTeamProvider = StreamProvider.autoDispose<bool>((ref) async* {
  final database = ref.read(databaseProvider);
  yield* observeCurrentTeamId(database).map((id) => id != null);
});

final currentChannelIdProvider = StreamProvider.autoDispose<String>((ref) async* {
  final database = ref.read(databaseProvider);
  yield* observeCurrentChannelId(database);
});

final isCRTEnabledProvider = StreamProvider.autoDispose<bool>((ref) async* {
  final database = ref.read(databaseProvider);
  yield* observeIsCRTEnabled(database);
});

class EnhancedAdditionalTabletView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final onTeam = watch(currentTeamProvider);
    final currentChannelId = watch(currentChannelIdProvider);
    final isCRTEnabled = watch(isCRTEnabledProvider);

    return AdditionalTabletView(
      onTeam: onTeam.data?.value ?? false,
      currentChannelId: currentChannelId.data?.value ?? '',
      isCRTEnabled: isCRTEnabled.data?.value ?? false,
    );
  }
}
