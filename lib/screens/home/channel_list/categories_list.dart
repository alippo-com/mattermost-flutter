import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:mattermost_flutter/components/threads_button.dart';
import 'package:mattermost_flutter/constants/view.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/screens/home/channel_list/categories.dart';
import 'package:mattermost_flutter/screens/home/channel_list/header.dart';
import 'package:mattermost_flutter/screens/home/channel_list/load_channels_error.dart';
import 'package:mattermost_flutter/screens/home/channel_list/subheader.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_reaction/flutter_reaction.dart';

class CategoriesList extends HookWidget {
  final bool hasChannels;
  final bool iconPad;
  final bool isCRTEnabled;
  final bool moreThanOneTeam;

  CategoriesList({
    required this.hasChannels,
    required this.iconPad,
    required this.isCRTEnabled,
    required this.moreThanOneTeam,
  });

  double getTabletWidth(bool moreThanOneTeam) {
    return TABLET_SIDEBAR_WIDTH - (moreThanOneTeam ? TEAM_SIDEBAR_WIDTH : 0);
  }

  @override
  Widget build(BuildContext context) {
    final theme = useTheme();
    final styles = getStyleSheet(theme);
    final width = MediaQuery.of(context).size.width;
    final isTablet = useIsTablet();
    final tabletWidth = useState(isTablet ? getTabletWidth(moreThanOneTeam) : 0.0);

    useEffect(() {
      if (isTablet) {
        tabletWidth.value = getTabletWidth(moreThanOneTeam);
      }
    }, [isTablet, moreThanOneTeam]);

    final tabletStyle = useAnimatedStyle(() {
      if (!isTablet) {
        return {
          'maxWidth': width,
        };
      }

      return {'maxWidth': withTiming(tabletWidth.value, duration: 350)};
    }, [isTablet, width]);

    final content = useMemo(() {
      if (!hasChannels) {
        return LoadChannelsError();
      }

      return Column(
        children: [
          SubHeader(),
          if (isCRTEnabled)
            ThreadsButton(
              isOnHome: true,
              shouldHighlightActive: true,
            ),
          Categories(),
        ],
      );
    }, [isCRTEnabled]);

    return AnimatedContainer(
      duration: Duration(milliseconds: 350),
      style: tabletStyle,
      child: Column(
        children: [
          ChannelListHeader(iconPad: iconPad),
          content,
        ],
      ),
    );
  }

  Map<String, dynamic> getStyleSheet(ThemeData theme) {
    return {
      'container': BoxDecoration(
        color: theme.sidebarBg,
        padding: EdgeInsets.only(top: 10),
      ),
    };
  }
}
