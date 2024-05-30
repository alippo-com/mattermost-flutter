
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:mattermost_flutter/types.dart'; // Assuming types directory for typing imports
import 'package:mattermost_flutter/components/loading.dart';
import 'package:mattermost_flutter/components/search.dart';
import 'package:mattermost_flutter/components/selected_users.dart';
import 'package:mattermost_flutter/components/server_user_list.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/navigation.dart';
import 'package:mattermost_flutter/utils/snack_bar.dart';
import 'package:mattermost_flutter/actions/remote/channel.dart';
import 'package:mattermost_flutter/constants.dart';
import 'package:mattermost_flutter/context/server.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/hooks/navigation_button_pressed.dart';

class ChannelAddMembers extends StatefulWidget {
  final String componentId;
  final ChannelModel? channel;
  final String currentUserId;
  final String teammateNameDisplay;
  final bool tutorialWatched;
  final bool inModal;

  ChannelAddMembers({
    required this.componentId,
    this.channel,
    required this.currentUserId,
    required this.teammateNameDisplay,
    required this.tutorialWatched,
    this.inModal = false,
  });

  @override
  _ChannelAddMembersState createState() => _ChannelAddMembersState();
}

class _ChannelAddMembersState extends State<ChannelAddMembers> {
  late ThemeData theme;
  late String serverUrl;
  late TextEditingController searchController;
  late Map<String, UserProfile> selectedIds;
  late bool addingMembers;
  late double containerHeight;

  @override
  void initState() {
    super.initState();
    theme = Theme.of(context);
    serverUrl = Provider.of<ServerContext>(context, listen: false).serverUrl;
    searchController = TextEditingController();
    selectedIds = {};
    addingMembers = false;
    containerHeight = 0.0;

    // Handle navigation button pressed
    useNavButtonPressed(CLOSE_BUTTON_ID, widget.componentId, _close);

    // Handle Android hardware back button pressed
    useAndroidHardwareBackHandler(widget.componentId, _close);

    // Update navigation buttons
    _updateNavigationButtons();
  }

  void _close() {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    Navigator.of(context).pop();
  }

  Future<void> _updateNavigationButtons() async {
    final options = await getHeaderOptions(theme, widget.channel?.displayName ?? '', widget.inModal);
    mergeNavigationOptions(widget.componentId, options);
  }

  Future<void> _addMembers() async {
    if (widget.channel == null || addingMembers) return;

    final idsToUse = selectedIds.keys.toList();
    if (idsToUse.isEmpty) return;

    setState(() {
      addingMembers = true;
    });

    final result = await addMembersToChannel(serverUrl, widget.channel!.id, idsToUse);
    if (result.error) {
      alertErrorWithFallback(context, result.error, 'There has been an error and we could not add those users to the channel.');
      setState(() {
        addingMembers = false;
      });
    } else {
      _close();
      showAddChannelMembersSnackbar(context, idsToUse.length);
    }
  }

  void _handleRemoveProfile(String id) {
    setState(() {
      selectedIds.remove(id);
    });
  }

  void _handleSelectProfile(UserProfile user) {
    setState(() {
      if (selectedIds.containsKey(user.id)) {
        selectedIds.remove(user.id);
      } else {
        selectedIds[user.id] = user;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final style = getStyleFromTheme(theme);

    if (addingMembers) {
      return Center(
        child: Loading(color: theme.primaryColor),
      );
    }

    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(12.0),
              child: Search(
                controller: searchController,
                placeholder: 'Search',
                onChange: (value) {
                  setState(() {
                    // Logic for search term change
                  });
                },
                onCancel: () {
                  searchController.clear();
                },
              ),
            ),
            Expanded(
              child: ServerUserList(
                currentUserId: widget.currentUserId,
                handleSelectProfile: _handleSelectProfile,
                selectedIds: selectedIds,
                term: searchController.text,
                tutorialWatched: widget.tutorialWatched,
                fetchFunction: (page) => fetchProfilesNotInChannel(
                  serverUrl,
                  widget.channel?.teamId ?? '',
                  widget.channel?.id ?? '',
                  widget.channel?.isGroupConstrained ?? false,
                  page,
                  General.PROFILE_CHUNK_SIZE,
                ),
                searchFunction: (term) => searchProfiles(
                  serverUrl,
                  term.toLowerCase(),
                  {
                    'team_id': widget.channel?.teamId ?? '',
                    'not_in_channel_id': widget.channel?.id ?? '',
                    'allow_inactive': false,
                  },
                ),
              ),
            ),
            SelectedUsers(
              selectedIds: selectedIds,
              onRemove: _handleRemoveProfile,
              onPress: _addMembers,
              buttonIcon: Icons.person_add,
              buttonText: 'Add Members',
            ),
          ],
        ),
      ),
    );
  }
}

const CLOSE_BUTTON_ID = 'close-add-member';
const TEST_ID = 'add_members';
const CLOSE_BUTTON_TEST_ID = 'close.button';

Future<Map<String, dynamic>> getHeaderOptions(ThemeData theme, String displayName, {bool inModal = false}) async {
  Icon? leftButton;
  if (!inModal) {
    leftButton = Icon(Icons.close, color: theme.iconTheme.color);
  }
  return {
    'topBar': {
      'subtitle': {
        'color': theme.textTheme.titleMedium?.color?.withOpacity(0.72),
        'text': displayName,
      },
      'leftButtons': leftButton != null ? [leftButton] : null,
      'backButton': inModal ? {'color': theme.iconTheme.color} : null,
    },
  };
}

Map<String, dynamic> getStyleFromTheme(ThemeData theme) {
  return {
    'container': BoxDecoration(
      color: theme.colorScheme.surface,
    ),
    'searchBar': EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
    'loadingContainer': BoxDecoration(
      color: theme.colorScheme.surface,
      height: 70.0,
      alignment: Alignment.center,
    ),
    'loadingText': TextStyle(
      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
    ),
    'noResultContainer': BoxDecoration(
      color: theme.colorScheme.surface,
      alignment: Alignment.center,
    ),
    'noResultText': TextStyle(
      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
    ),
  };
}
