// Dart Code
// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';

import 'package:mattermost_flutter/constants/view.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/components/team_sidebar/add_team.dart';
import 'package:mattermost_flutter/components/team_sidebar/team_list.dart';

class TeamSidebar extends StatefulWidget {
  final bool iconPad;
  final bool canJoinOtherTeams;
  final bool hasMoreThanOneTeam;

  TeamSidebar({this.iconPad = false, required this.canJoinOtherTeams, required this.hasMoreThanOneTeam});

  @override
  _TeamSidebarState createState() => _TeamSidebarState();
}

class _TeamSidebarState extends State<TeamSidebar> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _widthAnimation;
  late Animation<double> _marginTopAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );

    _widthAnimation = Tween<double>(
      begin: widget.hasMoreThanOneTeam ? TEAM_SIDEBAR_WIDTH : 0,
      end: widget.hasMoreThanOneTeam ? TEAM_SIDEBAR_WIDTH : 0,
    ).animate(_controller);

    _marginTopAnimation = Tween<double>(
      begin: widget.iconPad ? 44 : 0,
      end: widget.iconPad ? 44 : 0,
    ).animate(_controller);

    _controller.forward();
  }

  @override
  void didUpdateWidget(TeamSidebar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.iconPad != oldWidget.iconPad) {
      _marginTopAnimation = Tween<double>(
        begin: widget.iconPad ? 44 : 0,
        end: widget.iconPad ? 44 : 0,
      ).animate(_controller);
      _controller.forward(from: 0.0);
    }

    if (widget.hasMoreThanOneTeam != oldWidget.hasMoreThanOneTeam) {
      _widthAnimation = Tween<double>(
        begin: widget.hasMoreThanOneTeam ? TEAM_SIDEBAR_WIDTH : 0,
        end: widget.hasMoreThanOneTeam ? TEAM_SIDEBAR_WIDTH : 0,
      ).animate(_controller);
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = useTheme();
    final styles = getStyleSheet(theme);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: _widthAnimation.value,
          height: double.infinity,
          color: theme.sidebarBg,
          padding: EdgeInsets.only(top: 10),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  color: theme.sidebarHeaderBg,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(12),
                  ),
                ),
                margin: EdgeInsets.only(top: _marginTopAnimation.value),
                child: Column(
                  children: [
                    Expanded(child: TeamList(testID: 'team_sidebar.team_list')),
                    if (widget.canJoinOtherTeams) AddTeam(),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Map<String, dynamic> getStyleSheet(Theme theme) {
    return {
      'container': {
        'width': TEAM_SIDEBAR_WIDTH,
        'height': double.infinity,
        'backgroundColor': theme.sidebarBg,
        'paddingTop': 10.0,
      },
      'listContainer': {
        'backgroundColor': theme.sidebarHeaderBg,
        'borderTopRightRadius': 12.0,
        'flex': 1,
      },
      'iconMargin': {
        'marginTop': 44.0,
      },
    };
  }
}
