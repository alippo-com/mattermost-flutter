import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:mattermost_flutter/components/compass_icon.dart';
import 'package:mattermost_flutter/components/loading.dart';
import 'package:mattermost_flutter/components/search.dart';
import 'package:mattermost_flutter/components/selected_users.dart';
import 'package:mattermost_flutter/components/server_user_list.dart';
import 'package:mattermost_flutter/constants.dart';
import 'package:mattermost_flutter/hooks/navigation_button_pressed.dart';
import 'package:mattermost_flutter/services/channel_service.dart';
import 'package:mattermost_flutter/services/user_service.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/typography.dart';
import 'package:react_intl/react_intl.dart';
import 'package:sqflite/sqflite.dart';

class CreateDirectMessage extends HookWidget {
  final String componentId;
  final String currentTeamId;
  final String currentUserId;
  final bool restrictDirectMessage;
  final String teammateNameDisplay;
  final bool tutorialWatched;

  const CreateDirectMessage({
    required this.componentId,
    required this.currentTeamId,
    required this.currentUserId,
    required this.restrictDirectMessage,
    required this.teammateNameDisplay,
    required this.tutorialWatched,
  });

  @override
  Widget build(BuildContext context) {
    final serverUrl = useServerUrl();
    final theme = useTheme();
    final style = getStyleFromTheme(theme);
    final intl = useIntl();
    final formatMessage = intl.formatMessage;

    final mainView = useRef<Widget>(null);
    final containerHeight = useState(0.0);
    final keyboardOverlap = useKeyboardOverlap(mainView, containerHeight.value);

    final term = useState('');
    final startingConversation = useState(false);
    final selectedIds = useState<Map<String, UserProfile>>({});
    final showToast = useState(false);
    final selectedCount = selectedIds.value.keys.length;

    void clearSearch() {
      term.value = '';
    }

    void handleRemoveProfile(String id) {
      selectedIds.value = removeProfileFromList(selectedIds.value, id);
    }

    Future<bool> createDirectChannel(String id, [UserProfile? selectedUser]) async {
      final user = selectedUser ?? selectedIds.value[id]!;
      final displayName = displayUsername(user, intl.locale, teammateNameDisplay);
      final result = await makeDirectChannel(serverUrl, id, displayName);

      if (result.error) {
        alertErrorWithFallback(intl, result.error, 'mobile.open_dm.error', {
          'defaultMessage': "We couldn't open a direct message with {displayName}. Please check your connection and try again.",
        });
      }

      return result.error == null;
    }

    Future<bool> createGroupChannel(List<String> ids) async {
      final result = await makeGroupChannel(serverUrl, ids);

      if (result.error) {
        alertErrorWithFallback(intl, result.error, 'mobile.open_gm.error', {
          'defaultMessage': "We couldn't open a group message with those users. Please check your connection and try again.",
        });
      }

      return result.error == null;
    }

    Future<void> startConversation([Map<String, bool>? selectedId, UserProfile? selectedUser]) async {
      if (startingConversation.value) {
        return;
      }

      startingConversation.value = true;

      final idsToUse = selectedId?.keys.toList() ?? selectedIds.value.keys.toList();
      bool success;
      if (idsToUse.isEmpty) {
        success = false;
      } else if (idsToUse.length > 1) {
        success = await createGroupChannel(idsToUse);
      } else {
        success = await createDirectChannel(idsToUse[0], selectedUser);
      }

      if (success) {
        close();
      } else {
        startingConversation.value = false;
      }
    }

    void handleSelectProfile(UserProfile user) {
      if (user.id == currentUserId) {
        final selectedId = {currentUserId: true};
        startConversation(selectedId, user);
      } else {
        clearSearch();
        selectedIds.value = removeProfileFromList(selectedIds.value, user.id);
        if (!selectedIds.value.containsKey(user.id)) {
          if (selectedCount >= General.maxUsersInGM) {
            showToast.value = true;
            return;
          }
          selectedIds.value[user.id] = user;
        }
      }
    }

    void onLayout(Size size) {
      containerHeight.value = size.height;
    }

    void updateNavigationButtons() async {
      final closeIcon = await CompassIcon.getImageSource('close', 24, theme.sidebarHeaderTextColor);
      setButtons(componentId, {'leftButtons': [{'id': 'close-dms', 'icon': closeIcon, 'testID': 'close.create_direct_message.button'}]});
    }

    void onChangeText(String searchTerm) {
      term.value = searchTerm;
    }

    Future<List<UserProfile>> userFetchFunction(int page) async {
      var results;
      if (restrictDirectMessage) {
        results = await fetchProfilesInTeam(serverUrl, currentTeamId, page, General.profileChunkSize);
      } else {
        results = await fetchProfiles(serverUrl, page, General.profileChunkSize);
      }

      if (results.users?.isNotEmpty ?? false) {
        return results.users;
      }

      return [];
    }

    Future<List<UserProfile>> userSearchFunction(String searchTerm) async {
      final lowerCasedTerm = searchTerm.toLowerCase();
      var results;
      if (restrictDirectMessage) {
        results = await searchProfiles(serverUrl, lowerCasedTerm, {'team_id': currentTeamId, 'allow_inactive': true});
      } else {
        results = await searchProfiles(serverUrl, lowerCasedTerm, {'allow_inactive': true});
      }

      if (results.data != null) {
        return results.data;
      }

      return [];
    }

    bool userFilter(UserProfile p, List<UserProfile> exactMatches, String searchTerm) {
      if (selectedCount > 0 && p.id == currentUserId) {
        return false;
      }

      if (p.username == searchTerm || p.username.startsWith(searchTerm)) {
        exactMatches.add(p);
        return false;
      }

      return true;
    }

    useNavButtonPressed('close-dms', componentId, close, [close]);
    useAndroidHardwareBackHandler(componentId, close);

    useEffect(() {
      updateNavigationButtons();
    }, []);

    useEffect(() {
      showToast.value = selectedCount >= General.maxUsersInGM;
    }, [selectedCount]);

    if (startingConversation.value) {
      return Container(
        alignment: Alignment.center,
        color: theme.centerChannelBg,
        height: 70,
        child: Loading(color: theme.centerChannelColor),
      );
    }

    return SafeArea(
      child: Container(
        flex: 1,
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              child: Search(
                placeholder: formatMessage({'id': 'search_bar.search', 'defaultMessage': 'Search'}),
                cancelButtonTitle: formatMessage({'id': 'mobile.post.cancel', 'defaultMessage': 'Cancel'}),
                placeholderTextColor: changeOpacity(theme.centerChannelColor, 0.5),
                onChangeText: onChangeText,
                onCancel: clearSearch,
                autoCapitalize: 'none',
                keyboardAppearance: getKeyboardAppearanceFromTheme(theme),
                value: term.value,
              ),
            ),
            Expanded(
              child: ServerUserList(
                currentUserId: currentUserId,
                handleSelectProfile: handleSelectProfile,
                selectedIds: selectedIds.value,
                term: term.value,
                tutorialWatched: tutorialWatched,
                fetchFunction: userFetchFunction,
                searchFunction: userSearchFunction,
                createFilter: (exactMatches, searchTerm) => (p) => userFilter(p, exactMatches, searchTerm),
              ),
            ),
            SelectedUsers(
              keyboardOverlap: keyboardOverlap,
              showToast: showToast.value,
              setShowToast: (val) => showToast.value = val,
              toastIcon: 'check',
              toastMessage: formatMessage({'id': 'mobile.create_direct_message.max_limit_reached', 'defaultMessage': 'Group messages are limited to {maxCount} members'}, {'maxCount': General.maxUsersInGM}),
              selectedIds: selectedIds.value,
              onRemove: handleRemoveProfile,
              teammateNameDisplay: teammateNameDisplay,
              onPress: startConversation,
              buttonIcon: 'forum-outline',
              buttonText: formatMessage({'id': 'mobile.create_direct_message.start', 'defaultMessage': 'Start Conversation'}),
              maxUsers: General.maxUsersInGM,
            ),
          ],
        ),
      ),
    );
  }

  void close() {
    FocusScope.of(mainView.currentContext!).unfocus();
    dismissModal();
  }

  Map<String, dynamic> getStyleFromTheme(Theme theme) {
    return {
      'container': {'flex': 1},
      'searchBar': {'marginLeft': 12, 'marginRight': 12, 'marginVertical': 12},
      'loadingContainer': {
        'alignItems': 'center',
        'backgroundColor': theme.centerChannelBg,
        'height': 70,
        'justifyContent': 'center',
      },
      'loadingText': {'color': changeOpacity(theme.centerChannelColor, 0.6)},
      'noResultContainer': {
        'flexGrow': 1,
        'flexDirection': 'row',
        'alignItems': 'center',
        'justifyContent': 'center',
      },
      'noResultText': {'color': changeOpacity(theme.centerChannelColor, 0.5), ...typography('Body', 600, 'Regular')},
    };
  }

  Map<String, dynamic> removeProfileFromList(Map<String, UserProfile> list, String id) {
    final newSelectedIds = Map<String, UserProfile>.from(list);
    newSelectedIds.remove(id);
    return newSelectedIds;
  }
}