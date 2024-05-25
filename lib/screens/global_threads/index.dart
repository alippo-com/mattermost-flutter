
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';
import 'package:mattermost_flutter/components/navigation_header.dart';
import 'package:mattermost_flutter/components/other_mentions_badge.dart';
import 'package:mattermost_flutter/components/rounded_header_context.dart';
import 'package:mattermost_flutter/constants/screens.dart';
import 'package:mattermost_flutter/context/server.dart';
import 'package:mattermost_flutter/hooks/android_back_handler.dart';
import 'package:mattermost_flutter/hooks/device.dart';
import 'package:mattermost_flutter/hooks/header.dart';
import 'package:mattermost_flutter/hooks/team_switch.dart';
import 'package:mattermost_flutter/screens/navigation.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/typography.dart';

import 'threads_list.dart';

class GlobalThreads extends HookWidget {
  final String? componentId;
  final GlobalThreadsTab globalThreadsTab;

  GlobalThreads({this.componentId, required this.globalThreadsTab});

  @override
  Widget build(BuildContext context) {
    final serverUrl = useServerUrl();
    final intl = useIntl();
    final switchingTeam = useTeamSwitch();
    final isTablet = useIsTablet();
    final defaultHeight = useDefaultHeaderHeight();
    final tab = useState<GlobalThreadsTab>(globalThreadsTab);
    final mounted = useRef(false);

    final containerStyle = useMemo(() {
      final marginTop = defaultHeight;
      return {'flex': 1, 'marginTop': marginTop};
    }, [defaultHeight]);

    final headerLeftComponent = useMemo(() {
      if (isTablet) {
        return null;
      }
      return OtherMentionsBadge(channelId: Screens.GLOBAL_THREADS);
    }, [isTablet]);

    useEffect(() {
      mounted.current = true;
      return () {
        setGlobalThreadsTab(serverUrl, tab.value);
        mounted.current = false;
      };
    }, [serverUrl, tab.value]);

    final contextStyle = useMemo(() {
      return {'top': defaultHeight};
    }, [defaultHeight]);

    final onBackPress = useCallback(() {
      Keyboard.dismiss();
      popTopScreen(componentId);
    }, [componentId]);

    useAndroidHardwareBackHandler(componentId, onBackPress);

    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            NavigationHeader(
              showBackButton: !isTablet,
              isLargeTitle: false,
              onBackPress: onBackPress,
              title: intl.formatMessage(
                id: 'threads',
                defaultMessage: 'Threads',
              ),
              leftComponent: headerLeftComponent,
            ),
            Container(
              style: contextStyle,
              child: RoundedHeaderContext(),
            ),
            if (!switchingTeam)
              Expanded(
                child: Container(
                  style: containerStyle,
                  child: ThreadsList(
                    setTab: tab,
                    tab: tab.value,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
