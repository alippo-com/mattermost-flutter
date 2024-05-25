// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:provider/provider.dart';
import 'package:mattermost_flutter/constants/view.dart';
import 'package:mattermost_flutter/screens/navigation/bottom_sheet.dart';
import 'package:mattermost_flutter/utils/helpers.dart';
import 'package:mattermost_flutter/utils/push_proxy.dart';
import 'package:mattermost_flutter/utils/server.dart';
import 'package:mattermost_flutter/utils/tap.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/typography.dart';
import 'package:mattermost_flutter/widgets/compass_icon.dart';
import 'package:mattermost_flutter/widgets/loading_unreads.dart';
import 'package:mattermost_flutter/widgets/touchable_with_feedback.dart';
import 'package:mattermost_flutter/widgets/plus_menu.dart';
import 'package:mattermost_flutter/constants/push_proxy.dart';

const double PLUS_BUTTON_SIZE = 28.0;

class ChannelListHeader extends HookWidget {
  final bool canCreateChannels;
  final bool canJoinChannels;
  final bool canInvitePeople;
  final String? displayName;
  final bool? iconPad;
  final VoidCallback? onHeaderPress;
  final String pushProxyStatus;

  ChannelListHeader({
    required this.canCreateChannels,
    required this.canJoinChannels,
    required this.canInvitePeople,
    this.displayName,
    this.iconPad,
    this.onHeaderPress,
    required this.pushProxyStatus,
  });

  @override
  Widget build(BuildContext context) {
    final theme = useTheme();
    final intl = useIntl();
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final serverDisplayName = useServerDisplayName();
    final marginLeft = useState(iconPad == true ? 50.0 : 0.0);
    final serverUrl = useServerUrl();

    useEffect(() {
      marginLeft.value = iconPad == true ? 50.0 : 0.0;
    }, [iconPad]);

    void onPress() {
      final renderContent = () => PlusMenu(
            canCreateChannels: canCreateChannels,
            canJoinChannels: canJoinChannels,
            canInvitePeople: canInvitePeople,
          );

      final closeButtonId = 'close-plus-menu';
      int items = 1;
      int separators = 0;

      if (canCreateChannels) items++;
      if (canJoinChannels) items++;
      if (canInvitePeople) {
        items++;
        separators++;
      }

      bottomSheet(
        context: context,
        closeButtonId: closeButtonId,
        renderContent: renderContent,
        snapPoints: [
          1,
          bottomSheetSnapPoint(items, ITEM_HEIGHT, bottom) +
              (separators * SEPARATOR_HEIGHT)
        ],
        theme: theme,
        title: intl.formatMessage(
            id: 'home.header.plus_menu', defaultMessage: 'Options'),
      );
    }

    void onPushAlertPress() {
      if (pushProxyStatus == PUSH_PROXY_STATUS_NOT_AVAILABLE) {
        alertPushProxyError(intl);
      } else {
        alertPushProxyUnknown(intl);
      }
    }

    void onLogoutPress() {
      alertServerLogout(serverDisplayName, () => logout(serverUrl), intl);
    }

    Widget header;
    if (displayName != null) {
      header = Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: onHeaderPress,
                  child: Text(
                    displayName!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: typography(context, 'Heading', 700).copyWith(
                      color: theme.sidebarText,
                    ),
                  ),
                ),
                Row(
                  children: [
                    Text(
                      serverDisplayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: typography(context, 'Heading', 50).copyWith(
                        color: changeOpacity(theme.sidebarText, 0.64),
                      ),
                    ),
                    if (pushProxyStatus != PUSH_PROXY_STATUS_VERIFIED)
                      TouchableWithFeedback(
                        onPressed: onPushAlertPress,
                        child: CompassIcon(
                          name: 'alert-outline',
                          color: theme.errorTextColor,
                          size: 14.0,
                        ),
                      ),
                    LoadingUnreads(),
                  ],
                ),
              ],
            ),
          ),
          TouchableWithFeedback(
            onPressed: onPress,
            child: Container(
              height: PLUS_BUTTON_SIZE,
              width: PLUS_BUTTON_SIZE,
              decoration: BoxDecoration(
                color: changeOpacity(theme.sidebarText, 0.08),
                borderRadius: BorderRadius.circular(PLUS_BUTTON_SIZE / 2),
              ),
              child: Center(
                child: CompassIcon(
                  name: 'plus',
                  color: changeOpacity(theme.sidebarText, 0.8),
                  size: 18.0,
                ),
              ),
            ),
          ),
        ],
      );
    } else {
      header = Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              serverDisplayName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: typography(context, 'Body', 100, 'SemiBold').copyWith(
                color: changeOpacity(theme.sidebarText, 0.64),
              ),
            ),
          ),
          TouchableWithFeedback(
            onPressed: onLogoutPress,
            child: Text(
              intl.formatMessage(
                  id: 'account.logout', defaultMessage: 'Log out'),
              style: typography(context, 'Body', 100, 'SemiBold').copyWith(
                color: changeOpacity(theme.sidebarText, 0.64),
              ),
            ),
          ),
        ],
      );
    }

    return AnimatedContainer(
      duration: Duration(milliseconds: 350),
      margin: EdgeInsets.only(left: marginLeft.value),
      padding: EdgeInsets.all(HOME_PADDING),
      child: header,
    );
  }
}
