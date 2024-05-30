import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_flutter_app/app.dart';
import 'package:my_flutter_app/utils/logger.dart';
import 'package:my_flutter_app/utils/font_family.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure logging
  configureLogger();

  // Set font family
  setFontFamily();

  // Platform-specific configurations
  if (Platform.isAndroid) {
    // Enable layout animations
    SystemChannels.platform.invokeMethod('SystemNavigator.pop');
  }

  runApp(MyApp());
}

void configureLogger() {
  // Your logging configuration
}

void setFontFamily() {
  // Your font family configuration
}
