
// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mattermost_flutter/constants.dart';
import 'package:mattermost_flutter/hooks/use_did_update.dart';
import 'package:mattermost_flutter/screens/browse_channels/browse_channels.dart';
import 'package:mattermost_flutter/types/channel_model.dart';
import 'package:mattermost_flutter/types/my_channel_model.dart';
import 'package:mattermost_flutter/utils/channel_utils.dart';

class SearchHandler extends StatefulWidget {
  final String componentId;
  final String currentUserId;
  final String currentTeamId;
  final bool canCreateChannels;
  final List<MyChannelModel>? joinedChannels;
  final bool sharedChannelsEnabled;
  final bool canShowArchivedChannels;

  const SearchHandler({
    Key? key,
    required this.componentId,
    required this.currentUserId,
    required this.currentTeamId,
    required this.canCreateChannels,
    this.joinedChannels,
    required this.sharedChannelsEnabled,
    required this.canShowArchivedChannels,
  }) : super(key: key);

  @override
  _SearchHandlerState createState() => _SearchHandlerState();
}

class _SearchHandlerState extends State<SearchHandler> {
  static const int minChannelsLoaded = 10;
  static const String load = 'load';
  static const String stop = 'stop';

  List<ChannelModel> channels = [];
  List<ChannelModel> archivedChannels = [];
  List<ChannelModel> sharedChannels = [];
  List<ChannelModel> searchResults = [];
  List<ChannelModel> visibleChannels = [];
  bool loading = false;
  String term = '';
  String typeOfChannels = BrowseChannels.public;
  int publicPage = -1;
  int sharedPage = -1;
  int archivedPage = -1;
  bool nextPublic = true;
  bool nextShared = true;
  bool nextArchived = true;
  Timer? searchTimeout;

  @override
  void initState() {
    super.initState();
    _loadChannels();
  }

  void _loadChannels() {
    // Logic to load initial channels
  }

  void _fetchChannels(String type) {
    if (loading) return;

    setState(() {
      loading = true;
    });

    // Fetch channels based on type

    setState(() {
      loading = false;
    });
  }

  void _filterChannelsByType() {
    // Logic to filter channels by type
  }

  void _doSearchChannels(String text) {
    if (text.isNotEmpty) {
      setState(() {
        searchResults.clear();
        term = text;
        loading = true;
      });

      searchTimeout?.cancel();
      searchTimeout = Timer(Duration(milliseconds: 500), () async {
        // Perform search
        setState(() {
          loading = false;
        });
      });
    } else {
      _stopSearch();
    }
  }

  void _stopSearch() {
    setState(() {
      searchResults.clear();
      term = '';
    });
  }

  void _changeChannelType(String channelType) {
    setState(() {
      typeOfChannels = channelType;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BrowseChannels(
      currentTeamId: widget.currentTeamId,
      changeChannelType: _changeChannelType,
      channels: visibleChannels,
      loading: loading,
      onEndReached: () {
        if (!loading && term.isEmpty) {
          _fetchChannels(typeOfChannels);
        }
      },
      searchChannels: _doSearchChannels,
      stopSearch: _stopSearch,
      term: term,
      typeOfChannels: typeOfChannels,
    );
  }
}
