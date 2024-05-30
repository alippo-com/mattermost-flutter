import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:mattermost_flutter/types/device.dart'; // Assuming this contains DeviceContext equivalent

class DeviceHooks {
  static bool useSplitView(BuildContext context) {
    final deviceContext = Provider.of<DeviceContext>(context);
    return deviceContext.isSplitView;
  }

  static ValueNotifier<AppLifecycleState> useAppState() {
    final appState = ValueNotifier<AppLifecycleState>(WidgetsBinding.instance.lifecycleState ?? AppLifecycleState.resumed);

    WidgetsBinding.instance.addObserver(
      LifecycleEventHandler(
        detachedCallBack: () async => appState.value = AppLifecycleState.detached,
        inactiveCallBack: () async => appState.value = AppLifecycleState.inactive,
        pausedCallBack: () async => appState.value = AppLifecycleState.paused,
        resumedCallBack: () async => appState.value = AppLifecycleState.resumed,
      ),
    );

    return appState;
  }

  static bool useIsTablet(BuildContext context) {
    final deviceContext = Provider.of<DeviceContext>(context);
    return deviceContext.isTablet && !deviceContext.isSplitView;
  }

  static ValueNotifier<Map<String, double>> useKeyboardHeightWithDuration([GlobalKey<KeyboardTrackingViewState>? keyboardTracker]) {
    final keyboardHeight = ValueNotifier<Map<String, double>>({"height": 0, "duration": 0});
    final insets = MediaQuery.of(context).viewInsets;

    void updateValue(double height, double duration) {
      keyboardHeight.value = {"height": height, "duration": duration};
    }

    void keyboardShowHandler(KeyboardEvent event) async {
      if (keyboardTracker?.currentState != null) {
        final props = await keyboardTracker.currentState!.getNativeProps();
        if (props.keyboardHeight != null) {
          updateValue((props.trackingViewHeight + props.keyboardHeight) - 4, event.duration);
        } else {
          updateValue((props.trackingViewHeight + insets.bottom) - 4, event.duration);
        }
      } else {
        updateValue(event.endCoordinates.height, event.duration);
      }
    }

    void keyboardHideHandler(KeyboardEvent event) {
      updateValue(0, event.duration);
    }

    SystemChannels.textInput.setMessageHandler((message) {
      if (message.contains('TextInput.show')) {
        keyboardShowHandler(message);
      } else if (message.contains('TextInput.hide')) {
        keyboardHideHandler(message);
      }
      return null;
    });

    return keyboardHeight;
  }

  static double useKeyboardHeight([GlobalKey<KeyboardTrackingViewState>? keyboardTracker]) {
    return useKeyboardHeightWithDuration(keyboardTracker).value['height'] ?? 0;
  }

  static double useViewPosition(GlobalKey<ViewState> viewRef, List<Object> deps, BuildContext context) {
    final modalPosition = ValueNotifier<double>(0);
    final isTablet = useIsTablet(context);
    final height = useKeyboardHeight();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Platform.isIOS && isTablet) {
        final box = viewRef.currentContext?.findRenderObject() as RenderBox?;
        final position = box?.localToGlobal(Offset.zero).dy;
        if (position != null && position != modalPosition.value) {
          modalPosition.value = position;
        }
      }
    });

    return modalPosition.value;
  }

  static double useKeyboardOverlap(GlobalKey<ViewState> viewRef, double containerHeight, BuildContext context) {
    final keyboardHeight = useKeyboardHeight();
    final isTablet = useIsTablet(context);
    final viewPosition = useViewPosition(viewRef, [containerHeight], context);
    final dimensions = MediaQuery.of(context).size;
    final insets = MediaQuery.of(context).viewInsets;

    final bottomSpace = (dimensions.height - containerHeight - viewPosition);
    final tabletOverlap = (keyboardHeight - bottomSpace).clamp(0, double.infinity);
    final phoneOverlap = keyboardHeight + insets.bottom;
    final overlap = Platform.isIOS ? (isTablet ? tabletOverlap : phoneOverlap) : 0;

    return overlap;
  }
}

class LifecycleEventHandler extends WidgetsBindingObserver {
  final Future<void> Function()? detachedCallBack;
  final Future<void> Function()? inactiveCallBack;
  final Future<void> Function()? pausedCallBack;
  final Future<void> Function()? resumedCallBack;

  LifecycleEventHandler({
    this.detachedCallBack,
    this.inactiveCallBack,
    this.pausedCallBack,
    this.resumedCallBack,
  });

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.detached:
        await detachedCallBack?.call();
        break;
      case AppLifecycleState.inactive:
        await inactiveCallBack?.call();
        break;
      case AppLifecycleState.paused:
        await pausedCallBack?.call();
        break;
      case AppLifecycleState.resumed:
        await resumedCallBack?.call();
        break;
    }
  }
}