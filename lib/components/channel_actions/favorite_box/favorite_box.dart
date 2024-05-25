// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:mattermost_flutter/actions/remote/category.dart';
import 'package:mattermost_flutter/components/option_box.dart';
import 'package:mattermost_flutter/context/server.dart';
import 'package:mattermost_flutter/screens/navigation.dart';

class FavoriteBox extends StatelessWidget {
  final String channelId;
  final BoxDecoration? containerStyle;
  final bool isFavorited;
  final bool showSnackBar;
  final String? testID;

  FavoriteBox({
    required this.channelId,
    this.containerStyle,
    required this.isFavorited,
    this.showSnackBar = false,
    this.testID,
  });

  @override
  Widget build(BuildContext context) {
    final intl = Intl.message;
    final serverUrl = useServerUrl(context);

    Future<void> handleOnPress() async {
      await dismissBottomSheet();
      toggleFavoriteChannel(serverUrl, channelId, showSnackBar);
    }

    final favoriteActionTestId = isFavorited ? '\${testID}.unfavorite.action' : '\${testID}.favorite.action';

    return OptionBox(
      activeIconName: Icons.star,
      activeText: intl('channel_info.favorited', name: 'Favorited'),
      containerStyle: containerStyle,
      iconName: Icons.star_border,
      isActive: isFavorited,
      onPress: handleOnPress,
      testID: favoriteActionTestId,
      text: intl('channel_info.favorite', name: 'Favorite'),
    );
  }
}
