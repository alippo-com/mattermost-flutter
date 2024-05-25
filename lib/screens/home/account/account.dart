
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';
import 'package:mattermost_flutter/components/account_options.dart';
import 'package:mattermost_flutter/components/account_tablet_view.dart';
import 'package:mattermost_flutter/components/account_user_info.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/types/database/models/servers/user.dart';

class AccountScreen extends HookWidget {
  final UserModel? currentUser;
  final bool enableCustomUserStatuses;
  final bool showFullName;

  AccountScreen({
    required this.currentUser,
    required this.enableCustomUserStatuses,
    required this.showFullName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = useTheme();
    final start = useState(false);
    final route = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final insets = MediaQuery.of(context).padding;
    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;

    final tabletSidebarStyle = isTablet ? {'maxWidth': ViewConstants.TABLET_SIDEBAR_WIDTH} : null;

    final params = route['direction'] as String;
    final toLeft = params == 'left';

    void onLayout() {
      start.value = true;
    }

    final animated = useAnimatedStyle(() {
      if (start.value) {
        return {
          'opacity': withTiming(1, duration: Duration(milliseconds: 150)),
          'transform': [{'translateX': withTiming(0, duration: Duration(milliseconds: 150))}],
        };
      }

      return {
        'opacity': withTiming(0, duration: Duration(milliseconds: 150)),
        'transform': [{'translateX': withTiming(toLeft ? -25 : 25, duration: Duration(milliseconds: 150))}],
      };
    });

    final styles = getStyleSheet(theme);

    final content = currentUser != null
        ? SingleChildScrollView(
            child: Column(
              children: [
                AccountUserInfo(
                  user: currentUser!,
                  showFullName: showFullName,
                  theme: theme,
                ),
                AccountOptions(
                  enableCustomUserStatuses: enableCustomUserStatuses,
                  isTablet: isTablet,
                  user: currentUser!,
                  theme: theme,
                ),
              ],
            ),
          )
        : null;

    return SafeArea(
      child: Container(
        color: theme.sidebarBg,
        child: Column(
          children: [
            Container(
              height: insets.top,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      color: theme.sidebarBg,
                      child: tabletSidebarStyle != null ? Container() : null,
                    ),
                  ),
                  if (isTablet)
                    Container(
                      color: theme.centerChannelBg,
                      child: tabletSidebarStyle != null ? Container() : null,
                    ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: Duration(milliseconds: 150),
              onEnd: onLayout,
              transform: animated['transform'],
              opacity: animated['opacity'],
              child: Row(
                children: [
                  content ?? Container(),
                  if (isTablet)
                    Container(
                      color: theme.centerChannelBg,
                      child: Column(
                        children: [
                          AccountTabletView(),
                          Divider(color: changeOpacity(theme.centerChannelColor, 0.16)),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
