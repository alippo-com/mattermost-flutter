// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mattermost_flutter/actions/local/post.dart';
import 'package:mattermost_flutter/actions/remote/post.dart';
import 'package:mattermost_flutter/components/compass_icon.dart';
import 'package:mattermost_flutter/components/slide_up_panel_item.dart';
import 'package:mattermost_flutter/context/server.dart';
import 'package:mattermost_flutter/screens/navigation.dart';
import 'package:mattermost_flutter/utils/helpers.dart';
import 'package:mattermost_flutter/types/database/models/servers/post.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

const ITEM_HEIGHT = 50.0;

class Failed extends StatelessWidget {
  final PostModel post;
  final ThemeData theme;

  const Failed({
    Key? key,
    required this.post,
    required this.theme,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final intl = AppLocalizations.of(context)!;
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final serverUrl = context.read<ServerUrlProvider>().serverUrl;

    void onPress() {
      void renderContent(BuildContext context) {
        showModalBottomSheet(
          context: context,
          builder: (context) {
            return Container(
              height: bottomSheetSnapPoint(2, ITEM_HEIGHT, bottom),
              child: Column(
                children: [
                  SlideUpPanelItem(
                    leftIcon: Icons.send_outlined,
                    onPress: () {
                      Navigator.pop(context);
                      retryFailedPost(serverUrl, post);
                    },
                    text: intl.mobilePostFailedRetry,
                  ),
                  SlideUpPanelItem(
                    destructive: true,
                    leftIcon: Icons.close,
                    onPress: () {
                      Navigator.pop(context);
                      removePost(serverUrl, post);
                    },
                    text: intl.mobilePostFailedDelete,
                  ),
                ],
              ),
            );
          },
          isScrollControlled: true,
        );
      }

      renderContent(context);
    }

    return GestureDetector(
      onTap: onPress,
      child: Container(
        margin: EdgeInsets.only(left: 10),
        child: CompassIcon(
          name: Icons.info_outline,
          size: 26,
          color: theme.errorColor,
        ),
      ),
    );
  }
}
