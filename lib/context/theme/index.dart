
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:mattermost_flutter/constants/preferences.dart';
import 'package:mattermost_flutter/types/database/preference_model.dart';
import 'package:mattermost_flutter/queries/servers/preference.dart';
import 'package:mattermost_flutter/queries/servers/system.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:provider/provider.dart';

class ThemeProvider extends StatelessWidget {
  final String? currentTeamId;
  final Widget child;
  final List<PreferenceModel> themes;

  ThemeProvider({
    required this.currentTeamId,
    required this.child,
    required this.themes,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeNotifier(currentTeamId, themes),
      child: Consumer<ThemeNotifier>(
        builder: (context, themeNotifier, child) {
          return Theme(
            data: themeNotifier.theme,
            child: child!,
          );
        },
        child: child,
      ),
    );
  }
}

class ThemeNotifier with ChangeNotifier {
  ThemeData _theme;
  String? _currentTeamId;
  List<PreferenceModel> _themes;

  ThemeNotifier(this._currentTeamId, this._themes)
      : _theme = getTheme(_currentTeamId, _themes) {
    SchedulerBinding.instance.window.onPlatformBrightnessChanged = () {
      final newTheme = getTheme(_currentTeamId, _themes);
      if (_theme != newTheme) {
        _theme = newTheme;
        notifyListeners();
      }
    };
  }

  ThemeData get theme => _theme;

  static ThemeData getTheme(String? teamId, List<PreferenceModel> themes) {
    if (teamId != null) {
      final teamTheme = themes.firstWhere((t) => t.name == teamId,
          orElse: () => themes.isNotEmpty ? themes[0] : null);
      if (teamTheme?.value != null) {
        try {
          final theme =
              setThemeDefaults(ThemeData.from(colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue)));
          return theme;
        } catch (_) {
          // no theme change
        }
      }
    }

    return getDefaultThemeByAppearance();
  }

  static ThemeData getDefaultThemeByAppearance() {
    final brightness = SchedulerBinding.instance.window.platformBrightness;
    if (brightness == Brightness.dark) {
      return Preferences.THEMES.onyx;
    }
    return Preferences.THEMES.denim;
  }
}

class ThemeContext {
  static ThemeData of(BuildContext context) {
    return Provider.of<ThemeNotifier>(context).theme;
  }
}

Widget withTheme(Widget Function(BuildContext context, ThemeData theme) builder) {
  return Consumer<ThemeNotifier>(
    builder: (context, themeNotifier, child) {
      return builder(context, themeNotifier.theme);
    },
  );
}
