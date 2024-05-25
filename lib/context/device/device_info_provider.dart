
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class SplitViewResult {
  bool isRunningInSplitView;

  SplitViewResult(this.isRunningInSplitView);
}

class DeviceInfoProvider extends StatefulWidget {
  final Widget child;

  DeviceInfoProvider({required this.child});

  @override
  _DeviceInfoProviderState createState() => _DeviceInfoProviderState();
}

class _DeviceInfoProviderState extends State<DeviceInfoProvider> {
  late SplitViewResult deviceInfo;
  static const platform = MethodChannel('com.mattermost/splitview');
  late EventChannel eventChannel;

  @override
  void initState() {
    super.initState();
    deviceInfo = SplitViewResult(false); // Default value
    eventChannel = EventChannel('com.mattermost/splitview/events');
    _getInitialDeviceInfo();
    _listenToDeviceInfoChanges();
  }

  Future<void> _getInitialDeviceInfo() async {
    try {
      final bool result = await platform.invokeMethod('isRunningInSplitView');
      setState(() {
        deviceInfo = SplitViewResult(result);
      });
    } on PlatformException catch (e) {
      print("Failed to get initial device info: '${e.message}'.");
    }
  }

  void _listenToDeviceInfoChanges() {
    eventChannel.receiveBroadcastStream().listen((dynamic result) {
      setState(() {
        deviceInfo = SplitViewResult(result);
      });
    }, onError: (dynamic error) {
      print("Error receiving device info changes: '$error'.");
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SplitViewResult>.value(
      value: deviceInfo,
      child: widget.child,
    );
  }
}
