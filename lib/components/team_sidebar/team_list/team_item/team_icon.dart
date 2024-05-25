// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mattermost_flutter/types/theme.dart';
import 'package:mattermost_flutter/context/server.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/typography.dart';
import 'package:mattermost_flutter/managers/network_manager.dart';

class TeamIcon extends StatefulWidget {
  final String id;
  final int lastIconUpdate;
  final String displayName;
  final bool selected;
  final String? backgroundColor;
  final bool smallText;
  final String? textColor;
  final String? testID;

  const TeamIcon({
    required this.id,
    required this.lastIconUpdate,
    required this.displayName,
    required this.selected,
    this.backgroundColor,
    this.smallText = false,
    this.textColor,
    this.testID,
  });

  @override
  _TeamIconState createState() => _TeamIconState();
}

class _TeamIconState extends State<TeamIcon> {
  bool imageError = false;
  late NetworkManager client;
  late ThemeData theme;
  late Map<String, dynamic> styles;

  @override
  void initState() {
    super.initState();
    theme = useTheme(context);
    styles = getStyleSheet(theme);
    client = NetworkManager.getClient(useServerUrl(context))!;
  }

  Map<String, dynamic> getStyleSheet(ThemeData theme) {
    return {
      'container': BoxDecoration(
        color: theme.sidebarBg,
        borderRadius: BorderRadius.circular(8),
      ),
      'containerSelected': BoxDecoration(
        color: theme.sidebarBg,
        borderRadius: BorderRadius.circular(6),
      ),
      'text': TextStyle(
        color: theme.sidebarText,
        textTransform: TextTransform.uppercase,
      ),
      'image': BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      'nameOnly': BoxDecoration(
        color: changeOpacity(theme.sidebarText, 0.16),
      ),
    };
  }

  @override
  void didUpdateWidget(covariant TeamIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() {
      imageError = false;
    });
  }

  void handleImageError() {
    setState(() {
      imageError = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final nameOnly = imageError || widget.lastIconUpdate == 0 || client == null;
    final containerStyle = widget.selected
        ? (widget.backgroundColor != null
            ? styles['containerSelected'].copyWith(
                color: widget.backgroundColor,
              )
            : styles['containerSelected'])
        : (widget.backgroundColor != null
            ? styles['container'].copyWith(
                color: widget.backgroundColor,
              )
            : styles['container']);

    final textTypography = typography(
      'Heading',
      widget.smallText ? 200 : 400,
      'SemiBold',
    );
    textTypography.fontFamily = 'Metropolis-SemiBold';

    Widget teamIconContent;
    if (nameOnly) {
      final textStyle = textTypography.copyWith(
        color: widget.textColor ?? theme.sidebarText,
      );

      teamIconContent = Text(
        widget.displayName.substring(0, 2),
        style: textStyle,
        key: Key(widget.testID ?? 'display_name_abbreviation'),
      );
    } else {
      teamIconContent = CachedNetworkImage(
        imageUrl:
            '${useServerUrl(context)}${client.getTeamIconUrl(widget.id, widget.lastIconUpdate)}',
        imageBuilder: (context, imageProvider) => Container(
          decoration: styles['image'].copyWith(
            image: DecorationImage(
              image: imageProvider,
              fit: BoxFit.cover,
            ),
          ),
        ),
        errorWidget: (context, url, error) => Icon(Icons.error),
        onImageError: (error, stackTrace) => handleImageError(),
      );
    }

    return Container(
      decoration: containerStyle,
      child: Center(child: teamIconContent),
    );
  }
}
