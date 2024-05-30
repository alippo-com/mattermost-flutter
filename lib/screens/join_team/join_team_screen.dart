import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:mattermost_flutter/components/loading.dart';
import 'package:mattermost_flutter/components/formatted_text.dart';
import 'package:mattermost_flutter/components/illustrations/no_team.dart';
import 'package:mattermost_flutter/components/team_list.dart';
import 'package:mattermost_flutter/context/server.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/hooks/android_back_handler.dart';
import 'package:mattermost_flutter/hooks/navigation_button_pressed.dart';
import 'package:mattermost_flutter/screens/navigation.dart';
import 'package:mattermost_flutter/utils/log.dart';
import 'package:mattermost_flutter/utils/navigation.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class JoinTeam extends HookConsumerWidget {
  final Set<String> joinedIds;
  final String componentId;
  final String closeButtonId;

  const JoinTeam({
    Key? key,
    required this.joinedIds,
    required this.componentId,
    required this.closeButtonId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serverUrl = useServerUrl();
    final theme = useTheme();
    final styles = getStyleSheet(theme);
    final intl = useIntl();
    final page = useRef(0);
    final hasMore = useRef(true);
    final mounted = useRef(true);
    final loading = useState(true);
    final joining = useState(false);
    final otherTeams = useState<List<Team>>([]);

    final loadTeams = useCallback(() async {
      loading.value = true;
      final resp = await fetchTeamsForComponent(serverUrl, page.current, joinedIds);
      page.current = resp.page;
      hasMore.current = resp.hasMore;
      if (resp.teams.isNotEmpty && mounted.current) {
        final teams = resp.teams.where((t) => t.deleteAt == 0).toList();
        otherTeams.value = [...otherTeams.value, ...teams];
      }
      loading.value = false;
    }, [joinedIds, serverUrl]);

    final onEndReached = useCallback(() {
      if (hasMore.current && !loading.value) {
        loadTeams();
      }
    }, [loadTeams, loading.value]);

    final onPress = useCallback((teamId) async {
      joining.value = true;
      final error = await addCurrentUserToTeam(serverUrl, teamId);
      if (error != null) {
        alertTeamAddError(error, intl);
        logDebug('error joining a team:', error);
        joining.value = false;
      } else {
        handleTeamChange(serverUrl, teamId);
        dismissModal(componentId);
      }
    }, [serverUrl, componentId, intl]);

    useEffect(() {
      loadTeams();
      return () {
        mounted.current = false;
      };
    }, []);

    final onClosePressed = useCallback(() {
      return dismissModal(componentId);
    }, [componentId]);

    useNavButtonPressed(closeButtonId, componentId, onClosePressed, []);
    useAndroidHardwareBackHandler(componentId, onClosePressed);

    final hasOtherTeams = otherTeams.value.isNotEmpty;

    Widget body;
    if ((loading.value && !hasOtherTeams) || joining.value) {
      body = Loading(containerStyle: styles['loading']);
    } else if (hasOtherTeams) {
      body = TeamList(
        teams: otherTeams.value,
        onPress: onPress,
        testID: 'team_sidebar.add_team_slide_up.team_list',
        onEndReached: onEndReached,
        loading: loading.value,
      );
    } else {
      body = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Empty(theme: theme),
          FormattedText(
            id: 'team_list.no_other_teams.title',
            defaultMessage: 'No additional teams to join',
            style: styles['title'],
            testID: 'team_sidebar.add_team_slide_up.no_other_teams.title',
          ),
          FormattedText(
            id: 'team_list.no_other_teams.description',
            defaultMessage: 'To join another team, ask a Team Admin for an invitation, or create your own team.',
            style: styles['description'],
            testID: 'team_sidebar.add_team_slide_up.no_other_teams.description',
          ),
        ],
      );
    }

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: body,
      ),
    );
  }

  Map<String, dynamic> getStyleSheet(Theme theme) {
    return {
      'container': {
        'paddingHorizontal': 10,
        'paddingVertical': 5,
        'flex': 1,
      },
      'empty': {
        'flex': 1,
        'alignItems': 'center',
        'justifyContent': 'center',
      },
      'loading': {
        'flex': 1,
        'alignItems': 'center',
        'justifyContent': 'center',
      },
      'title': {
        'color': theme.centerChannelColor,
        'marginTop': 16,
        'fontWeight': FontWeight.w400,
        'fontSize': 24,
      },
      'description': {
        'color': theme.centerChannelColor,
        'marginTop': 8,
        'maxWidth': 334,
        'fontWeight': FontWeight.w200,
        'fontSize': 16,
      },
    };
  }
}