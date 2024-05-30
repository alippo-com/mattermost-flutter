import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:mattermost_flutter/components/loading.dart';
import 'package:mattermost_flutter/context/server.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/utils/log.dart';
import 'package:mattermost_flutter/utils/navigation.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'header.dart';
import 'no_teams.dart';
import 'team_list.dart';

final teamProvider = StateNotifierProvider<TeamNotifier, TeamState>((ref) {
  return TeamNotifier(ref.read);
});

class SelectTeam extends HookConsumerWidget {
  final int nTeams;
  final String? firstTeamId;

  const SelectTeam({
    Key? key,
    required this.nTeams,
    this.firstTeamId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = useTheme();
    final styles = getStyleSheet(theme);
    final serverUrl = useServerUrl();
    final intl = useIntl();
    final insets = useSafeAreaInsets();
    final resettingToHome = useRef(false);
    final loading = useState(true);
    final joining = useState(false);
    final top = useAnimatedStyle(() => {
        return {'height': insets.top, 'backgroundColor': theme.sidebarBg};
    });

    final page = useRef(0);
    final hasMore = useRef(true);

    final mounted = useRef(false);

    final otherTeams = useState<List<Team>>([]);

    final loadTeams = useCallback(() async {
      loading.value = true;
      final resp = await fetchTeamsForComponent(serverUrl, page.current);
      page.current = resp.page;
      hasMore.current = resp.hasMore;
      if (resp.teams.isNotEmpty && mounted.current) {
        final teams = resp.teams.where((t) => t.deleteAt == 0).toList();
        otherTeams.value = [...otherTeams.value, ...teams];
      }
      loading.value = false;
    }, [serverUrl]);

    final onEndReached = useCallback(() {
      if (hasMore.current && !loading.value) {
        loadTeams();
      }
    }, [loadTeams, loading.value]);

    final onTeamPressed = useCallback((teamId) async {
      joining.value = true;
      final error = await addCurrentUserToTeam(serverUrl, teamId);
      if (error != null) {
        alertTeamAddError(error, intl);
        logDebug('error joining a team:', error);

        joining.value = false;
      }

      // Back to home handled in an effect
    }, [serverUrl, intl]);

    useEffect(() {
      mounted.current = true;
      return () {
        mounted.current = false;
      };
    }, []);

    useEffect(() {
      if (resettingToHome.current) {
        return;
      }

      if (nTeams > 0 && firstTeamId != null) {
        resettingToHome.current = true;
        handleTeamChange(serverUrl, firstTeamId).then(() {
          resetToHome();
        });
      }
    }, [nTeams > 0 && firstTeamId != null]);

    useEffect(() {
      loadTeams();
    }, []);

    Widget body;
    if (joining.value || (loading.value && otherTeams.value.isEmpty)) {
      body = Loading(containerStyle: styles.loading);
    } else if (otherTeams.value.isNotEmpty) {
      body = TeamList(
        teams: otherTeams.value,
        onEndReached: onEndReached,
        onPress: onTeamPressed,
        loading: loading.value,
      );
    } else {
      body = NoTeams();
    }

    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: insets.top,
              color: theme.sidebarBg,
            ),
            Expanded(
              child: Container(
                color: theme.sidebarBg,
                child: Column(
                  children: [
                    Header(),
                    Expanded(child: body),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  getStyleSheet(Theme theme) {
    return {
      'container': {
        'flex': 1,
        'backgroundColor': theme.sidebarBg,
      },
      'loading': {
        'flex': 1,
        'alignItems': 'center',
        'justifyContent': 'center',
      },
    };
  }
}
