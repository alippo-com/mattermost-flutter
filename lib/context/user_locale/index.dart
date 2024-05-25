
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Assuming localization is handled similarly
import 'package:mattermost_flutter/types/calls.dart'; // Assuming necessary types and actions are defined here
import 'package:mattermost_flutter/components/option_box.dart'; // Assuming this component exists
import 'package:mattermost_flutter/utils/tap.dart'; // Assuming a utility for preventing double-tap exists

class UserLocaleProvider extends ChangeNotifier {
  String _locale;
  
  UserLocaleProvider(this._locale);
  
  String get locale => _locale;
  
  set locale(String newLocale) {
    if (_locale != newLocale) {
      _locale = newLocale;
      notifyListeners();
    }
  }
}

class UserLocaleProviderWidget extends StatelessWidget {
  final String locale;
  final Widget child;
  
  UserLocaleProviderWidget({required this.locale, required this.child});
  
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UserLocaleProvider(locale),
      child: child,
    );
  }
}

String useUserLocale(BuildContext context) {
  return Provider.of<UserLocaleProvider>(context).locale;
}

Widget withUserLocale(Widget Function(BuildContext, String) builder) {
  return Consumer<UserLocaleProvider>(
    builder: (context, userLocaleProvider, child) {
      return builder(context, userLocaleProvider.locale);
    },
  );
}

class EnhancedThemeProvider extends StatelessWidget {
  final Widget Function(BuildContext, String) builder;
  final Database database; // Assuming Database type exists
  
  EnhancedThemeProvider({required this.builder, required this.database});
  
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<String>(
      stream: observeCurrentUser(database).switchMap((user) {
        return Stream.value(user?.locale ?? DEFAULT_LOCALE); // Assuming observeCurrentUser and DEFAULT_LOCALE are defined
      }),
      builder: (context, snapshot) {
        final locale = snapshot.data ?? DEFAULT_LOCALE;
        
        return UserLocaleProviderWidget(
          locale: locale,
          child: builder(context, locale),
        );
      },
    );
  }
}
