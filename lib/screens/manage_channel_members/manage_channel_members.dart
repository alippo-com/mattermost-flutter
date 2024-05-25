import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mattermost_flutter/actions/remote/channel.dart';
import 'package:mattermost_flutter/actions/remote/user.dart';
import 'package:mattermost_flutter/components/search.dart';
import 'package:mattermost_flutter/components/user_list.dart';
import 'package:mattermost_flutter/constants.dart';
import 'package:mattermost_flutter/context/server.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/hooks/android_back_handler.dart';
import 'package:mattermost_flutter/hooks/navigation_button_pressed.dart';
import 'package:mattermost_flutter/screens/navigation.dart';
import 'package:mattermost_flutter/store/navigation_store.dart';
import 'package:mattermost_flutter/utils/snack_bar.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/user.dart';
import 'package:provider/provider.dart';

class ManageChannelMembers extends StatefulWidget {
  final bool canManageAndRemoveMembers;
  final String channelId;
  final String componentId;
  final String currentTeamId;
  final String currentUserId;
  final bool tutorialWatched;
  final String teammateDisplayNameSetting;

  ManageChannelMembers({
    required this.canManageAndRemoveMembers,
    required this.channelId,
    required this.componentId,
    required this.currentTeamId,
    required this.currentUserId,
    required this.tutorialWatched,
    required this.teammateDisplayNameSetting,
  });

  @override
  _ManageChannelMembersState createState() => _ManageChannelMembersState();
}

class _ManageChannelMembersState extends State<ManageChannelMembers> {
  final TextEditingController _searchController = TextEditingController();
  bool _isManageMode = false;
  bool _loading = true;
  List<UserProfile> _profiles = [];
  List<ChannelMembership> _channelMembers = [];
  List<UserProfile> _searchResults = [];
  String _term = '';
  String _searchedTerm = '';
  int _page = 0;
  bool _hasMoreProfiles = true;

  @override
  void initState() {
    super.initState();
    _fetchChannelMembers();
    SystemChannels.lifecycle.setMessageHandler((message) {
      if (message == AppLifecycleState.resumed.toString()) {
        _fetchChannelMembers();
      }
      return Future.value();
    });
  }

  void _fetchChannelMembers() async {
    final serverUrl = Provider.of<Server>(context, listen: false).serverUrl;
    final options = {'sort': 'admin', 'active': true, 'per_page': PER_PAGE_DEFAULT, 'page': _page};
    final result = await fetchChannelMemberships(serverUrl, widget.channelId, options, true);
    setState(() {
      _loading = false;
      if (result['users'].length < PER_PAGE_DEFAULT) {
        _hasMoreProfiles = false;
      }
      if (result['users'].isNotEmpty) {
        _profiles.addAll(result['users']);
        _channelMembers.addAll(result['members']);
      }
    });
  }

  void _toggleManageEnabled() {
    setState(() {
      _isManageMode = !_isManageMode;
    });
  }

  void _onSearch(String text) {
    setState(() {
      _term = text;
      if (text.isEmpty) {
        _searchResults.clear();
        _searchedTerm = '';
      } else {
        _searchUsers(text);
      }
    });
  }

  void _searchUsers(String searchTerm) async {
    final serverUrl = Provider.of<Server>(context, listen: false).serverUrl;
    final lowerCasedTerm = searchTerm.toLowerCase();
    final options = {'team_id': widget.currentTeamId, 'in_channel_id': widget.channelId, 'allow_inactive': false};
    final result = await searchProfiles(serverUrl, lowerCasedTerm, options);
    setState(() {
      _searchResults = result['data'];
      _searchedTerm = searchTerm;
    });
  }

  void _handleSelectProfile(UserProfile profile) {
    // Implement the logic for selecting a profile
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<Theme>(context).theme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Channel Members'),
        actions: [
          IconButton(
            icon: Icon(_isManageMode ? Icons.done : Icons.manage_accounts),
            onPressed: _toggleManageEnabled,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: _onSearch,
              ),
            ),
            Expanded(
              child: UserList(
                currentUserId: widget.currentUserId,
                handleSelectProfile: _handleSelectProfile,
                loading: _loading,
                manageMode: _isManageMode,
                profiles: _term.isEmpty ? _profiles : _searchResults,
                channelMembers: _channelMembers,
                selectedIds: {},
                showManageMode: widget.canManageAndRemoveMembers && _isManageMode,
                showNoResults: !_loading && (_term.isNotEmpty && _searchResults.isEmpty),
                term: _searchedTerm,
                tutorialWatched: widget.tutorialWatched,
                includeUserMargin: true,
                fetchMore: _fetchChannelMembers,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
