// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:mattermost_flutter/actions/channel_actions.dart';
import 'package:mattermost_flutter/components/channel_item.dart';
import 'package:mattermost_flutter/constants.dart';
import 'package:mattermost_flutter/models/channel_model.dart';
import 'package:mattermost_flutter/models/category_model.dart';
import 'package:mattermost_flutter/utils/channel_utils.dart';
import 'package:mattermost_flutter/utils/animation_utils.dart';

class CategoryBody extends StatefulWidget {
  final List<ChannelModel> sortedChannels;
  final CategoryModel category;
  final Function(Channel channel) onChannelSwitch;
  final Set<String> unreadIds;
  final bool unreadsOnTop;

  CategoryBody({
    required this.sortedChannels,
    required this.category,
    required this.onChannelSwitch,
    required this.unreadIds,
    required this.unreadsOnTop,
  });

  @override
  _CategoryBodyState createState() => _CategoryBodyState();
}

class _CategoryBodyState extends State<CategoryBody> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _heightAnimation;
  late List<ChannelModel> ids;
  late List<ChannelModel> unreadChannels;
  late List<ChannelModel> directChannels;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    _updateChannelLists();
    _initAnimations();
  }

  void _updateChannelLists() {
    ids = widget.unreadsOnTop
        ? widget.sortedChannels.where((c) => !widget.unreadIds.contains(c.id)).toList()
        : widget.sortedChannels;

    unreadChannels = widget.unreadsOnTop ? [] : ids.where((c) => widget.unreadIds.contains(c.id)).toList();
    directChannels = (ids + unreadChannels).where(isDMorGM).toList();
  }

  void _initAnimations() {
    final height = ids.length * CHANNEL_ROW_HEIGHT;
    final unreadHeight = unreadChannels.length * CHANNEL_ROW_HEIGHT;

    _heightAnimation = Tween<double>(
      begin: widget.category.collapsed ? unreadHeight : height,
      end: widget.category.collapsed ? unreadHeight : height,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    if (widget.category.collapsed) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(CategoryBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.category.collapsed != widget.category.collapsed) {
      _initAnimations();
    }
    _updateChannelLists();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      sizeFactor: _heightAnimation,
      child: ListView.builder(
        itemCount: widget.category.collapsed ? unreadChannels.length : ids.length,
        itemBuilder: (context, index) {
          final channel = widget.category.collapsed ? unreadChannels[index] : ids[index];
          return ChannelItem(
            channel: channel,
            onPress: widget.onChannelSwitch,
            key: Key(channel.id),
            shouldHighlightActive: true,
            shouldHighlightState: true,
            isOnHome: true,
          );
        },
      ),
    );
  }
}
