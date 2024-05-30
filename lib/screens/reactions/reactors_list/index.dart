// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:mattermost_flutter/context/server.dart';
import 'package:mattermost_flutter/screens/reactions/reactors_list/reactor.dart';
import 'package:mattermost_flutter/types/database/models/servers/reaction.dart';
import 'package:mattermost_flutter/utils/pan_responder.dart';

class ReactorsList extends StatefulWidget {
  final String location;
  final List<ReactionModel> reactions;
  final String type;

  ReactorsList({
    required this.location,
    required this.reactions,
    this.type = 'FlatList',
  });

  @override
  _ReactorsListState createState() => _ReactorsListState();
}

class _ReactorsListState extends State<ReactorsList> {
  late bool enabled;
  late String direction;
  late ScrollController listController;
  late double prevOffset;
  late PanResponder panResponder;

  @override
  void initState() {
    super.initState();
    enabled = false;
    direction = 'down';
    listController = ScrollController();
    prevOffset = 0.0;

    panResponder = PanResponder(
      onMoveShouldSetPanResponderCapture: (details) {
        setState(() {
          direction = prevOffset < details.delta.dy ? 'down' : 'up';
          prevOffset = details.delta.dy;
          if (!enabled && direction == 'up') {
            enabled = true;
          }
        });
        return false;
      },
    );

    final userIds = widget.reactions.map((r) => r.userId).toList();
    fetchUsersByIds(useServerUrl(), userIds);
  }

  @override
  Widget build(BuildContext context) {
    final renderItem = (BuildContext context, int index) {
      final item = widget.reactions[index];
      return Reactor(
        location: widget.location,
        reaction: item,
      );
    };

    if (widget.type == 'BottomSheetFlatList') {
      return BottomSheet(
        onClosing: () {},
        builder: (context) {
          return ListView.builder(
            itemCount: widget.reactions.length,
            itemBuilder: renderItem,
            controller: listController,
            physics: AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
          );
        },
      );
    }

    return ListView.builder(
      itemCount: widget.reactions.length,
      itemBuilder: renderItem,
      controller: listController,
      onScrollNotification: (ScrollNotification notification) {
        if (notification.metrics.pixels <= 0 && enabled && direction == 'down') {
          setState(() {
            enabled = false;
            listController.animateTo(0.0, duration: Duration(milliseconds: 300), curve: Curves.easeOut);
          });
        }
        return false;
      },
      physics: enabled ? AlwaysScrollableScrollPhysics() : NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
    );
  }
}
