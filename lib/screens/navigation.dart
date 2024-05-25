import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mattermost_flutter/constants.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/store/ephemeral_store.dart';
import 'package:mattermost_flutter/store/navigation_store.dart';
import 'package:mattermost_flutter/utils/helpers.dart';
import 'package:mattermost_flutter/utils/log.dart';
import 'package:mattermost_flutter/utils/navigation.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:tinycolor2/tinycolor2.dart';

class NavigationService {
  static final List<StreamSubscription> _subscriptions = [];

  static const List<DeviceOrientation> allOrientations = [
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ];

  static const List<DeviceOrientation> portraitOrientation = [
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ];

  static void registerNavigationListeners() {
    for (var subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions
      ..add(Navigation.events().onScreenPopped.listen(_onPoppedListener))
      ..add(Navigation.events().onCommand.listen(_onCommandListener))
      ..add(Navigation.events().onComponentWillAppear.listen(_onScreenWillAppear));
  }

  static void _onCommandListener(CommandEvent event) {
    switch (event.name) {
      case 'setRoot':
        NavigationStore.clearScreensFromStack();
        NavigationStore.addScreenToStack(event.layoutRoot.children.first.id);
        break;
      case 'push':
        NavigationStore.addScreenToStack(event.layoutId);
        break;
      case 'showModal':
        NavigationStore.addModalToStack(event.layout.children.first.id);
        break;
      case 'popToRoot':
        NavigationStore.clearScreensFromStack();
        NavigationStore.addScreenToStack(Screens.home);
        break;
      case 'popTo':
        NavigationStore.popTo(event.componentId);
        break;
      case 'dismissModal':
        NavigationStore.removeModalFromStack(event.componentId);
        break;
    }

    if (NavigationStore.getVisibleScreen() == Screens.home) {
      eventBus.emit(Events.tabBarVisible, true);
    }
  }

  static void _onPoppedListener(ScreenPoppedEvent event) {
    NavigationStore.removeScreenFromStack(event.componentId);
  }

  static void _onScreenWillAppear(ComponentWillAppearEvent event) {
    if (event.componentId == Screens.home) {
      eventBus.emit(Events.tabBarVisible, true);
    }
  }

  static Map<String, dynamic> loginAnimationOptions() {
    final theme = getThemeFromState();
    return {
      'layout': {
        'backgroundColor': theme.centerChannelBg,
        'componentBackgroundColor': theme.centerChannelBg,
      },
      'topBar': {
        'visible': true,
        'drawBehind': true,
        'translucid': true,
        'noBorder': true,
        'elevation': 0,
        'background': {'color': Colors.transparent},
        'backButton': {
          'color': changeOpacity(theme.centerChannelColor, 0.56),
        },
        'scrollEdgeAppearance': {
          'active': true,
          'noBorder': true,
          'translucid': true,
        },
      },
      'animations': {
        'topBar': {'alpha': alpha},
        'push': {
          'waitForRender': false,
          'content': {'alpha': alpha},
        },
        'pop': {
          'content': {
            'alpha': {
              'from': 1,
              'to': 0,
              'duration': 100,
            },
          },
        },
      },
    };
  }

  static Options bottomSheetModalOptions(Theme theme, {String? closeButtonId}) {
    if (closeButtonId != null) {
      final closeButton = CompassIcon.getImageSourceSync('close', 24, theme.centerChannelColor);
      final closeButtonTestId = closeButtonId.replaceFirst('close-', 'close.').replaceAll('-', '_') + '.button';
      return Options(
        modalPresentationStyle: OptionsModalPresentationStyle.formSheet,
        topBar: TopBarOptions(
          leftButtons: [
            TopBarButton(
              id: closeButtonId,
              icon: closeButton,
              testID: closeButtonTestId,
            ),
          ],
          leftButtonColor: changeOpacity(theme.centerChannelColor, 0.56),
          background: BackgroundOptions(color: theme.centerChannelBg),
          title: TitleOptions(color: theme.centerChannelColor),
        ),
      );
    }

    return Options(
      animations: AnimationsOptions(
        showModal: AnimationOptions(enabled: false),
        dismissModal: AnimationOptions(enabled: false),
      ),
      modalPresentationStyle: Platform.isIOS
          ? OptionsModalPresentationStyle.overFullScreen
          : OptionsModalPresentationStyle.overCurrentContext,
      statusBar: StatusBarOptions(
        backgroundColor: null,
        drawBehind: true,
        translucent: true,
      ),
    );
  }

  static void setScreensOrientation(bool allowRotation) {
    final options = Options(
      layout: LayoutOptions(
        orientation: allowRotation ? allOrientations : portraitOrientation,
      ),
    );
    Navigation.setDefaultOptions(options);
    final screens = NavigationStore.getScreensInStack();
    for (final screen in screens) {
      Navigation.mergeOptions(screen, options);
    }
  }

  static Theme getThemeFromState() {
    return EphemeralStore.theme ?? getDefaultThemeByAppearance();
  }

  static bool isScreenRegistered(AvailableScreens screen) {
    final notImplemented = NOT_READY.contains(screen) || !Screens.values.contains(screen);
    if (notImplemented) {
      showAlert('Temporary error $screen', 'The functionality you are trying to use has not been implemented yet');
      return false;
    }
    return true;
  }

  static void openToS() {
    NavigationStore.setToSOpen(true);
    showOverlay(Screens.termsOfService, {}, OverlayOptions(interceptTouchOutside: true));
  }

  static void resetToHome({LaunchProps launchProps = const LaunchProps(launchType: Launch.normal)}) {
    final theme = getThemeFromState();
    final isDark = TinyColor(theme.sidebarBg).isDark();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
    ));

    if (launchProps.launchType == Launch.addServer || launchProps.launchType == Launch.addServerFromDeepLink) {
      dismissModal(componentId: Screens.server);
      dismissModal(componentId: Screens.login);
      dismissModal(componentId: Screens.sso);
      dismissModal(componentId: Screens.bottomSheet);
      if (launchProps.launchType == Launch.addServerFromDeepLink) {
        Navigation.updateProps(Screens.home, {'launchType': Launch.deepLink, 'extra': launchProps.extra});
      }
      return;
    }

    final stack = Stack(children: [
      Component(
        id: Screens.home,
        name: Screens.home,
        passProps: launchProps,
        options: Options(
          layout: LayoutOptions(componentBackgroundColor: theme.centerChannelBg),
          statusBar: StatusBarOptions(
            visible: true,
            backgroundColor: theme.sidebarBg,
          ),
          topBar: TopBarOptions(
            visible: false,
            height: 0,
            background: BackgroundOptions(color: theme.sidebarBg),
            backButton: BackButtonOptions(
              visible: false,
              color: theme.sidebarHeaderTextColor,
            ),
          ),
        ),
      ),
    ]);

    Navigation.setRoot(Root(stack: stack));
  }

  static void resetToSelectServer(LaunchProps passProps) {
    final theme = getDefaultThemeByAppearance();
    final isDark = TinyColor(theme.sidebarBg).isDark();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
    ));

    final children = [
      Component(
        id: Screens.server,
        name: Screens.server,
        passProps: {...passProps, 'theme': theme},
        options: Options(
          layout: LayoutOptions(
            backgroundColor: theme.centerChannelBg,
            componentBackgroundColor: theme.centerChannelBg,
          ),
          statusBar: StatusBarOptions(
            visible: true,
            backgroundColor: theme.sidebarBg,
          ),
          topBar: TopBarOptions(
            backButton: BackButtonOptions(
              color: theme.sidebarHeaderTextColor,
              title: '',
            ),
            background: BackgroundOptions(color: theme.sidebarBg),
            visible: false,
            height: 0,
          ),
        ),
      ),
    ];

    Navigation.setRoot(Root(stack: Stack(children: children)));
  }

  // Other methods omitted for brevity...
}
