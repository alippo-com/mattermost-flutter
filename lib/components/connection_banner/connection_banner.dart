import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_reaction/flutter_reaction.dart'; // This is a hypothetical package for reanimated-like behavior in Flutter

import 'package:mattermost_flutter/components/compass_icon.dart';
import 'package:mattermost_flutter/constants/view.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/typography.dart';

class ConnectionBanner extends HookWidget {
  final String websocketState;

  ConnectionBanner({
    required this.websocketState,
  });

  @override
  Widget build(BuildContext context) {
    final intl = Intl.of(context);
    final closeTimeout = useRef<Timer?>(null);
    final openTimeout = useRef<Timer?>(null);
    final height = useSharedValue(0.0);
    final theme = useTheme(context);
    final visible = useState(false);
    final appState = useAppState();
    final netInfo = useConnectivity();

    final isConnected = websocketState == 'connected';

    final openCallback = useCallback(() {
      visible.value = true;
      clearTimeoutRef(openTimeout);
    }, []);

    final closeCallback = useCallback(() {
      visible.value = false;
      clearTimeoutRef(closeTimeout);
    }, []);

    useEffect(() {
      if (websocketState == 'connecting') {
        openCallback();
      } else if (!isConnected) {
        openTimeout.value = Timer(Duration(seconds: 3), openCallback);
      }
      return () {
        clearTimeoutRef(openTimeout);
        clearTimeoutRef(closeTimeout);
      };
    }, []);

    useDidUpdate(() {
      if (isConnected) {
        if (visible.value) {
          if (closeTimeout.value == null) {
            closeTimeout.value = Timer(Duration(seconds: 1), closeCallback);
          }
        } else {
          clearTimeoutRef(openTimeout);
        }
      } else if (visible.value) {
        clearTimeoutRef(closeTimeout);
      } else if (appState == 'active') {
        visible.value = true;
      }
    }, [isConnected]);

    useDidUpdate(() {
      if (appState == 'active') {
        if (!isConnected && !visible.value) {
          if (openTimeout.value == null) {
            openTimeout.value = Timer(Duration(seconds: 3), openCallback);
          }
        }
        if (isConnected && visible.value) {
          if (closeTimeout.value == null) {
            closeTimeout.value = Timer(Duration(seconds: 1), closeCallback);
          }
        }
      } else {
        visible.value = false;
        clearTimeoutRef(openTimeout);
        clearTimeoutRef(closeTimeout);
      }
    }, [appState == 'active']);

    useEffect(() {
      height.value = withTiming(visible.value ? ANNOUNCEMENT_BAR_HEIGHT : 0, duration: Duration(milliseconds: 200));
    }, [visible.value]);

    final bannerStyle = useAnimatedStyle(() => {
      return {'height': height.value};
    });

    String text;
    if (isConnected) {
      text = intl.formatMessage({'id': 'connection_banner.connected', 'defaultMessage': 'Connection restored'});
    } else if (websocketState == 'connecting') {
      text = intl.formatMessage({'id': 'connection_banner.connecting', 'defaultMessage': 'Connecting...'});
    } else if (netInfo.isInternetReachable) {
      text = intl.formatMessage({'id': 'connection_banner.not_reachable', 'defaultMessage': 'The server is not reachable'});
    } else {
      text = intl.formatMessage({'id': 'connection_banner.not_connected', 'defaultMessage': 'No internet connection'});
    }

    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      height: height.value,
      decoration: BoxDecoration(
        color: theme.sidebarBg,
      ),
      child: Row(
        children: [
          if (visible.value)
            Expanded(
              child: Row(
                children: [
                  CompassIcon(
                    color: theme.centerChannelBg,
                    name: isConnected ? 'check' : 'information-outline',
                    size: 18,
                  ),
                  const SizedBox(width: 4.0),
                  Text(
                    text,
                    style: typography('Body', 100, 'SemiBold').merge(TextStyle(color: theme.centerChannelBg)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void clearTimeoutRef(ValueNotifier<Timer?> ref) {
    ref.value?.cancel();
    ref.value = null;
  }
}
