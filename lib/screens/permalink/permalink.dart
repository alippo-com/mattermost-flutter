// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:mattermost_flutter/actions/local/post.dart';
import 'package:mattermost_flutter/actions/remote/channel.dart';
import 'package:mattermost_flutter/actions/remote/post.dart';
import 'package:mattermost_flutter/actions/remote/team.dart';
import 'package:mattermost_flutter/components/compass_icon.dart';
import 'package:mattermost_flutter/components/formatted_text.dart';
import 'package:mattermost_flutter/components/loading.dart';
import 'package:mattermost_flutter/components/post_list.dart';
import 'package:mattermost_flutter/context/server.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/database/manager.dart';
import 'package:mattermost_flutter/queries/servers/channel.dart';
import 'package:mattermost_flutter/utils/permalink.dart';
import 'package:mattermost_flutter/utils/tap.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/typography.dart';
import 'package:mattermost_flutter/types.dart';
import 'package:mattermost_flutter/types/channel_model.dart';
import 'package:mattermost_flutter/types/post_model.dart';
import 'package:mattermost_flutter/screens/permalink/permalink_error.dart';

class Permalink extends StatefulWidget {
  final ChannelModel? channel;
  final String? rootId;
  final String? teamName;
  final bool? isTeamMember;
  final String currentTeamId;
  final bool isCRTEnabled;
  final String postId;

  Permalink({
    this.channel,
    this.rootId,
    this.teamName,
    this.isTeamMember,
    required this.currentTeamId,
    required this.isCRTEnabled,
    required this.postId,
  });

  @override
  _PermalinkState createState() => _PermalinkState();
}

class _PermalinkState extends State<Permalink> {
  final List<PostModel> posts = [];
  bool loading = true;
  Theme theme;
  String serverUrl;
  EdgeInsets insets;
  bool isTablet;
  dynamic style;
  PermalinkErrorType? error;
  String? channelId;

  @override
  void initState() {
    super.initState();
    theme = useTheme(context);
    serverUrl = useServerUrl(context);
    insets = MediaQuery.of(context).viewPadding;
    isTablet = useIsTablet(context);
    style = _getStyleSheet(theme);
    error = null;
    channelId = widget.channel?.id;

    _fetchData();
  }

  Future<void> _fetchData() async {
    if (channelId != null) {
      var data;
      final loadThreadPosts = widget.isCRTEnabled && widget.rootId != null;
      if (loadThreadPosts) {
        data = await fetchPostThread(serverUrl, widget.rootId!, fetchAll: true);
      } else {
        data = await fetchPostsAround(serverUrl, channelId!, widget.postId, POSTS_LIMIT, widget.isCRTEnabled);
      }
      if (data.error != null) {
        setState(() {
          error = PermalinkErrorType(unreachable: true);
        });
      }
      if (data.posts != null) {
        final ids = data.posts.map((post) => post.id).toList();
        final postsModels = await getPosts(serverUrl, ids, 'desc');
        setState(() {
          posts = loadThreadPosts ? _processThreadPosts(postsModels, widget.postId) : postsModels;
          loading = false;
        });
      }
      return;
    }
  
    final database = DatabaseManager.serverDatabases[serverUrl]?.database;
    if (database == null) {
      setState(() {
        error = PermalinkErrorType(unreachable: true);
        loading = false;
      });
      return;
    }
  
    let joinedTeam;
    if (widget.teamName != null && widget.isTeamMember == null) {
      final fetchData = await fetchTeamByName(serverUrl, widget.teamName!, true);
      joinedTeam = fetchData.team;
  
      if (joinedTeam != null) {
        final addData = await addCurrentUserToTeam(serverUrl, joinedTeam.id);
        if (addData.error != null) {
          joinedTeam = null;
        }
      }
    }
  
    final fetchPostData = await fetchPostById(serverUrl, widget.postId, true);
    final post = fetchPostData.post;
    if (post == null) {
      if (joinedTeam != null) {
        removeCurrentUserFromTeam(serverUrl, joinedTeam.id);
      }
      setState(() {
        error = PermalinkErrorType(notExist: true);
        loading = false;
      });
      return;
    }
  
    final myChannel = await getMyChannel(database, post.channelId);
    if (myChannel != null) {
      final localChannel = await getChannelById(database, myChannel.id);
      if (joinedTeam != null && localChannel?.teamId.isNotEmpty == true && localChannel?.teamId != joinedTeam.id) {
        removeCurrentUserFromTeam(serverUrl, joinedTeam.id);
        joinedTeam = null;
      }
  
      if (joinedTeam != null) {
        setState(() {
          error = PermalinkErrorType(
            joinedTeam: true,
            channelId: myChannel.id,
            channelName: localChannel?.displayName,
            privateTeam: !joinedTeam.allowOpenInvite,
            teamName: joinedTeam.displayName,
            teamId: joinedTeam.id,
          );
          loading = false;
        });
        return;
      }
      setState(() {
        channelId = post.channelId;
      });
      return;
    }
  
    final fetchChannelData = await fetchChannelById(serverUrl, post.channelId);
    final fetchedChannel = fetchChannelData.channel;
    if (fetchedChannel == null) {
      if (joinedTeam != null) {
        removeCurrentUserFromTeam(serverUrl, joinedTeam.id);
      }
      setState(() {
        error = PermalinkErrorType(notExist: true);
        loading = false;
      });
      return;
    }
  
    if (joinedTeam != null && fetchedChannel.teamId.isNotEmpty == true && fetchedChannel.teamId != joinedTeam.id) {
      removeCurrentUserFromTeam(serverUrl, joinedTeam.id);
      joinedTeam = null;
    }
  
    setState(() {
      error = PermalinkErrorType(
        privateChannel: fetchedChannel.type == 'P',
        joinedTeam: joinedTeam != null,
        channelId: fetchedChannel.id,
        channelName: fetchedChannel.displayName,
        teamId: fetchedChannel.teamId.isEmpty ? widget.currentTeamId : fetchedChannel.teamId,
        teamName: joinedTeam?.displayName,
        privateTeam: joinedTeam != null && !joinedTeam.allowOpenInvite,
      );
      loading = false;
    });
  }

  List<PostModel> _processThreadPosts(List<PostModel> posts, String postId) {
    posts.sort((a, b) => b.createAt - a.createAt);
    final postIndex = posts.indexWhere((p) => p.id == postId);
    final start = postIndex - POSTS_LIMIT;
    return posts.sublist(start < 0 ? postIndex : start, postIndex + POSTS_LIMIT + 1);
  }

  void _handleClose() {
    if (error?.joinedTeam == true && error?.teamId != null) {
      removeCurrentUserFromTeam(serverUrl, error?.teamId);
    }
    dismissModal(Screens.PERMALINK);
    closePermalink();
  }

  void _handlePress() {
    if (widget.channel != null) {
      switchToChannelById(serverUrl, widget.channel!.id, widget.channel!.teamId);
    }
  }

  void _handleJoin() async {
    setState(() {
      loading = true;
      error = null;
    });
    if (error?.teamId != null && error?.channelId != null) {
      final joinData = await joinChannel(serverUrl, error!.teamId!, error!.channelId!);
      if (joinData.error != null) {
        showAlert('Error joining the channel', 'There was an error trying to join the channel');
        setState(() {
          loading = false;
          error = error;
        });
        return;
      }
      setState(() {
        channelId = error?.channelId;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final containerStyle = [
      style['container'],
      {
        'marginTop': isTablet ? 60.0 : 20.0,
        'marginBottom': insets.bottom + (isTablet ? 60.0 : 20.0),
      },
    ];

    Widget content;
    if (loading) {
      content = Center(
        child: Loading(color: theme.buttonBg),
      );
    } else if (error != null) {
      content = PermalinkError(
        error: error,
        handleClose: _handleClose,
        handleJoin: _handleJoin,
      );
    } else {
      content = Column(
        children: [
          Expanded(
            child: PostList(
              highlightedId: widget.postId,
              isCRTEnabled: widget.isCRTEnabled,
              posts: posts,
              location: Screens.PERMALINK,
              lastViewedAt: 0,
              shouldShowJoinLeaveMessages: false,
              channelId: widget.channel!.id,
              rootId: widget.rootId,
              testID: 'permalink.post_list',
              nativeID: Screens.PERMALINK,
              highlightPinnedOrSaved: false,
            ),
          ),
          Container(
            padding: EdgeInsets.all(20.0),
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(12.0),
                bottomRight: Radius.circular(12.0),
              ),
              border: Border(
                top: BorderSide(
                  color: changeOpacity(theme.centerChannelColor, 0.16),
                  width: 1.0,
                ),
              ),
            ),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.buttonBg,
                textStyle: buttonTextStyle(theme, 'lg', 'primary'),
              ),
              onPressed: _handlePress,
              child: FormattedText(
                id: 'mobile.search.jump',
                defaultMessage: 'Jump to recent messages',
                style: buttonTextStyle(theme, 'lg', 'primary'),
              ),
            ),
          ),
        ],
      );
    }

    final showHeaderDivider = widget.channel?.displayName != null && error == null && !loading;
    return SafeArea(
      child: Container(
        style: containerStyle,
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12.0),
                  topRight: Radius.circular(12.0),
                ),
                border: Border.all(
                  color: changeOpacity(theme.centerChannelColor, 0.16),
                  width: 1.0,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: CompassIcon(
                      name: 'close',
                      size: 24.0,
                      color: theme.centerChannelColor,
                    ),
                    onPressed: _handleClose,
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        if (widget.isCRTEnabled && widget.rootId != null) ...[
                          FormattedText(
                            id: 'thread.header.thread',
                            defaultMessage: 'Thread',
                            style: style['title'],
                          ),
                          FormattedText(
                            id: 'thread.header.thread_in',
                            defaultMessage: 'in {channelName}',
                            values: {'channelName': widget.channel?.displayName},
                            style: style['description'],
                          ),
                        ] else ...[
                          Text(
                            widget.channel?.displayName ?? '',
                            style: style['title'],
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (showHeaderDivider)
              Divider(
                color: changeOpacity(theme.centerChannelColor, 0.2),
                height: 1.0,
              ),
            Expanded(child: content),
          ],
        ),
      ),
    );
  }
}
