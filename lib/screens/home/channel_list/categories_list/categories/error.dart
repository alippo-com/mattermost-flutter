
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:mattermost_flutter/actions/remote/retry.dart';
import 'package:mattermost_flutter/components/loading_error.dart';
import 'package:mattermost_flutter/context/server.dart';
import 'package:mattermost_flutter/store/team_load_store.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LoadCategoriesError extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final intl = AppLocalizations.of(context)!;
    final serverUrl = useServerUrl();
    final serverName = useServerDisplayName();
    final loading = useState(false);

    Future<void> onRetryTeams() async {
      loading.value = true;
      setTeamLoading(serverUrl, true);
      final error = await retryInitialTeamAndChannel(serverUrl);
      setTeamLoading(serverUrl, false);

      if (error != null) {
        loading.value = false;
      }
    }

    return LoadingError(
      loading: loading.value,
      message: intl.loadCategoriesErrorMessage,
      onRetry: onRetryTeams,
      title: intl.loadCategoriesErrorTitle(serverName),
    );
  }
}
