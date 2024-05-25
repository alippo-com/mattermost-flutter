
// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mattermost_flutter/constants.dart';
import 'package:mattermost_flutter/database/components.dart';
import 'package:mattermost_flutter/i18n.dart';
import 'package:mattermost_flutter/screens.dart';
import 'package:mattermost_flutter/types.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class EMMProvider extends StatelessWidget {
  final Widget child;

  const EMMProvider({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Implement necessary EMM provider functionality here
    return child;
  }
}

Widget withGestures(Widget screen, [BoxDecoration? decoration]) {
  return GestureDetector(
    onTap: () {
      // Implement gesture functionality if needed
    },
    child: Container(
      decoration: decoration,
      child: screen,
    ),
  );
}

Widget withIntl(Widget screen) {
  return Localizations(
    locale: const Locale(DEFAULT_LOCALE),
    delegates: [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    child: screen,
  );
}

Widget withSafeAreaInsets(Widget screen) {
  return SafeArea(
    child: screen,
  );
}

Widget withManagedConfig(Widget screen) {
  return EMMProvider(
    child: screen,
  );
}

void registerScreens() {
  // Registering screens with appropriate wrappers
  Map<String, WidgetBuilder> routes = {
    Screens.ABOUT: (_) => withServerDatabase(AboutScreen()),
    Screens.APPS_FORM: (_) => withServerDatabase(AppsFormScreen()),
    // Add other screen registrations here
    Screens.HOME: (_) => withGestures(withSafeAreaInsets(withServerDatabase(withManagedConfig(HomeScreen())))),
    Screens.SERVER: (_) => withGestures(withIntl(withManagedConfig(ServerScreen()))),
    Screens.ONBOARDING: (_) => withGestures(withIntl(withManagedConfig(OnboardingScreen()))),
  };

  runApp(MaterialApp(
    // Define your theme and other properties here
    localizationsDelegates: [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: [
      const Locale('en', ''), // English, no country code
      // Add other supported locales here
    ],
    routes: routes,
  ));
}
