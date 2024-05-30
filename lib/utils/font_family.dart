// Converted from ./mattermost-mobile/app/utils/font_family.ts

import 'package:flutter/material.dart';

void setFontFamily() {
  // Define a custom TextStyle
  const defaultTextStyle = TextStyle(
    fontFamily: 'OpenSans',
    fontSize: 16,
  );

  // Create a custom TextTheme
  final customTextTheme = TextTheme(
    bodyMedium: defaultTextStyle,
  );

  // Apply the custom TextTheme to the ThemeData
  runApp(
    MaterialApp(
      theme: ThemeData(
        textTheme: customTextTheme,
      ),
      home: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Hello, World!'),
      ),
    );
  }
}
