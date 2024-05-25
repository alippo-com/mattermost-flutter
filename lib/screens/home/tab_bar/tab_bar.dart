
// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_reanimated/flutter_reanimated.dart';
import 'package:flutter_safe_area/flutter_safe_area.dart';
import 'package:mattermost_flutter/constants/events.dart';
import 'package:mattermost_flutter/constants/navigation.dart';
import 'package:mattermost_flutter/constants/view.dart';
import 'package:mattermost_flutter/store/navigation_store.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/screens/home/tab_bar/account.dart';
import 'package:mattermost_flutter/screens/home/tab_bar/home.dart';
import 'package:mattermost_flutter/screens/home/tab_bar/mentions.dart';
import 'package:mattermost_flutter/screens/home/tab_bar/saved_messages.dart';
import 'package:mattermost_flutter/screens/home/tab_bar/search.dart';

class TabBar extends HookWidget {
  final List<Route> stateRoutes;
  final Map<String, dynamic> descriptors;
  final dynamic navigation;
  final ThemeData theme;

  TabBar({
    required this.stateRoutes,
    required this.descriptors,
    required this.navigation,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final visible = useState<bool?>(null);
    final width = MediaQuery.of(context).size.width;
    final tabWidth = width / stateRoutes.length;
    final safeAreaInsets = MediaQuery.of(context).padding;
    final style = _getStyleSheet(theme);

    useEffect(() {
      final event = EventEmitter.on(Events.TAB_BAR_VISIBLE, (show) {
        visible.value = show;
      });

      return () => EventEmitter.off(Events.TAB_BAR_VISIBLE, event);
    }, []);

    useEffect(() {
      final listener = EventEmitter.on(NavigationConstants.NAVIGATION_HOME, () {
        NavigationStore.setVisibleTap(Screens.HOME);
        navigation.navigate(Screens.HOME);
      });

      return () => EventEmitter.off(NavigationConstants.NAVIGATION_HOME, listener);
    }, []);

    useEffect(() {
      final listener = EventEmitter.on(NavigationConstants.NAVIGATE_TO_TAB, (data) {
        final screen = data['screen'];
        final params = data['params'] ?? {};
        final lastTab = stateRoutes.last;
        final routeIndex = stateRoutes.indexWhere((r) => r.name == screen);
        final route = stateRoutes[routeIndex];
        final lastIndex = stateRoutes.indexWhere((r) => r.key == lastTab.key);
        final direction = lastIndex < routeIndex ? 'right' : 'left';
        final event = navigation.emit('tabPress', {'target': screen, 'canPreventDefault': true});

        if (!event.defaultPrevented) {
          navigation.navigate(route.name, {'params': {'direction': direction, ...params}});
          NavigationStore.setVisibleTap(route.name);
        }
      });

      return () => EventEmitter.off(NavigationConstants.NAVIGATE_TO_TAB, listener);
    }, [stateRoutes]);

    final transform = useAnimatedStyle(() {
      final translateX = withTiming(stateRoutes.index * tabWidth, duration: 150);
      return {'transform': [{'translateX': translateX}]};
    });

    final animatedStyle = useAnimatedStyle(() {
      if (visible.value == null) {
        return {'transform': [{'translateY': -safeAreaInsets.bottom}]};
      }

      final height = visible.value!
          ? withTiming(-safeAreaInsets.bottom, duration: 200)
          : withTiming(52 + safeAreaInsets.bottom, duration: 150);
      return {'transform': [{'translateY': height}]};
    });

    return AnimatedBuilder(
      animation: Listenable.merge([transform, animatedStyle]),
      builder: (context, child) {
        return Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Color.fromRGBO(61, 60, 64, 0.08),
                      blurRadius: 4,
                      offset: Offset(0, -0.5),
                    ),
                  ],
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
            Transform(
              transform: Matrix4.translationValues(transform.value['translateX'], 0, 0),
              child: Container(
                width: tabWidth - 20,
                alignment: Alignment.topCenter,
                child: Container(
                  width: 48,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.buttonColor,
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(4)),
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: Row(
                children: stateRoutes.map((route) {
                  final index = stateRoutes.indexOf(route);
                  final options = descriptors[route.key];
                  final isFocused = state.index == index;

                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        final lastTab = stateRoutes.last;
                        final lastIndex = stateRoutes.indexOf(lastTab);
                        final direction = lastIndex < index ? 'right' : 'left';
                        final event = navigation.emit('tabPress', {'target': route.key, 'canPreventDefault': true});
                        EventEmitter.emit('tabPress');

                        if (!isFocused && !event.defaultPrevented) {
                          navigation.navigate(route.name, {'params': {'direction': direction}});
                          NavigationStore.setVisibleTap(route.name);
                        }
                      },
                      onLongPress: () {
                        navigation.emit('tabLongPress', {'target': route.key});
                      },
                      child: Center(
                        child: _renderOption(route.name, isFocused, theme),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _renderOption(String routeName, bool isFocused, ThemeData theme) {
    switch (routeName) {
      case 'Account':
        return Account(isFocused: isFocused, theme: theme);
      case 'Home':
        return Home(isFocused: isFocused, theme: theme);
      case 'Mentions':
        return Mentions(isFocused: isFocused, theme: theme);
      case 'SavedMessages':
        return SavedMessages(isFocused: isFocused, theme: theme);
      case 'Search':
        return Search(isFocused: isFocused, theme: theme);
      default:
        return Container();
    }
  }

  Map<String, dynamic> _getStyleSheet(ThemeData theme) {
    return {
      'container': {
        'backgroundColor': theme.scaffoldBackgroundColor,
        'alignContent': 'center',
        'flexDirection': Axis.horizontal,
        'height': ViewConstants.BOTTOM_TAB_HEIGHT,
        'justifyContent': MainAxisAlignment.center,
      },
      'item': {
        'alignItems': Alignment.center,
        'flex': 1,
        'justifyContent': MainAxisAlignment.center,
      },
      'separator': {
        'borderTopColor': theme.dividerColor.withOpacity(0.08),
        'borderTopWidth': 0.5,
      },
      'slider': {
        'backgroundColor': theme.buttonColor,
        'borderBottomLeftRadius': 4,
        'borderBottomRightRadius': 4,
        'width': 48,
        'height': 4,
      },
      'sliderContainer': {
        'height': 4,
        'position': 'absolute',
        'top': 0,
        'left': 10,
        'alignItems': Alignment.center,
      },
      'shadowBorder': {
        'borderRadius': 6,
      },
    };
  }
}
