
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class DeviceContext extends ChangeNotifier {
  late SplitViewResult info;

  DeviceContext() {
    _init();
  }

  Future<void> _init() async {
    const platform = MethodChannel('com.example/splitview');
    try {
      final result = await platform.invokeMethod<SplitViewResult>('isRunningInSplitView');
      info = result;
      notifyListeners();

      platform.setMethodCallHandler((call) async {
        if (call.method == 'SplitViewChanged') {
          final newResult = call.arguments as SplitViewResult;
          info = newResult;
          notifyListeners();
        }
      });
    } on PlatformException {
      // Handle exception
    }
  }
}

class DeviceInfoProvider extends StatelessWidget {
  final Widget child;

  DeviceInfoProvider({required this.child});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DeviceContext(),
      child: child,
    );
  }
}

class SplitViewResult {
  // Define properties and methods based on your needs
}
