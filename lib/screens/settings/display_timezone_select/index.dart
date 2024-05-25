// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:mattermost_flutter/components/search.dart';
import 'package:mattermost_flutter/context/server.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/hooks/android_back_handler.dart';
import 'package:mattermost_flutter/screens/navigation.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/user.dart';
import 'package:react_intl/intl.dart';

import 'timezone_row.dart';
import 'package:mattermost_flutter/types/screens/navigation.dart';

class SelectTimezones extends HookWidget {
  final AvailableScreens componentId;
  final void Function(String) onBack;
  final String currentTimezone;

  SelectTimezones({
    required this.componentId,
    required this.onBack,
    required this.currentTimezone,
  });

  @override
  Widget build(BuildContext context) {
    final intl = IntlShape.of(context);
    final serverUrl = useServerUrl(context);
    final theme = useTheme(context);
    final styles = getStyleSheet(theme);

    final cancelButtonProps = useMemo(
      () => {
        'buttonTextStyle': {
          'color': changeOpacity(theme.centerChannelColor, 0.64),
          'fontSize': 14.0,
        },
        'buttonStyle': {
          'marginTop': 12.0,
        },
      },
      [theme.centerChannelColor],
    );

    final timezones = useState<List<String>>([]);
    final initialScrollIndex = useState<int?>(null);
    final searchRegion = useState<String?>(null);

    final filteredTimezones = useCallback(
      () {
        if (searchRegion.value == null) {
          return timezones.value;
        }
        final lowerCasePrefix = searchRegion.value!.toLowerCase();

        if (initialScrollIndex.value != null) {
          initialScrollIndex.value = null;
        }

        return timezones.value.where((t) {
          return getTimezoneRegion(t).toLowerCase().contains(lowerCasePrefix) ||
              t.toLowerCase().contains(lowerCasePrefix);
        }).toList();
      },
      [searchRegion.value, timezones.value, initialScrollIndex.value],
    );

    final close = useCallback(
      (newTimezone) {
        onBack(newTimezone ?? currentTimezone);
        popTopScreen(componentId);
      },
      [currentTimezone, componentId],
    );

    final onPressTimezone = useCallback(
      (selectedTimezone) {
        close(selectedTimezone);
      },
      [],
    );

    final renderItem = useCallback(
      (context, timezone) {
        return TimezoneRow(
          isSelected: timezone == currentTimezone,
          onPressTimezone: onPressTimezone,
          timezone: timezone,
        );
      },
      [currentTimezone, onPressTimezone],
    );

    useEffect(() {
      Future<void> getSupportedTimezones() async {
        final allTzs = await getAllSupportedTimezones(serverUrl);
        if (allTzs.isNotEmpty) {
          timezones.value = allTzs;
          final timezoneIndex = allTzs.indexWhere((timezone) => timezone == currentTimezone);
          if (timezoneIndex > 0) {
            initialScrollIndex.value = timezoneIndex;
          }
        }
      }

      getSupportedTimezones();
    }, []);

    useAndroidHardwareBackHandler(componentId, close);

    return SafeArea(
      child: GestureDetector(
        onTap: () {
          if (searchRegion.value != null && searchRegion.value!.isNotEmpty) {
            searchRegion.value = '';
          }
        },
        child: Column(
          children: [
            Search(
              autoCapitalize: TextCapitalization.none,
              cancelButtonProps: cancelButtonProps,
              inputContainerStyle: styles['searchBarInputContainerStyle'],
              containerStyle: styles['searchBarContainerStyle'],
              inputStyle: styles['searchBarInput'],
              keyboardAppearance: getKeyboardAppearanceFromTheme(theme),
              onChangeText: searchRegion.value =,
              placeholder: intl.formatMessage('search_bar.search.placeholder', defaultMessage: 'Search timezone'),
              placeholderTextColor: changeOpacity(theme.centerChannelColor, 0.5),
              selectionColor: changeOpacity(theme.centerChannelColor, 0.5),
              testID: 'select_timezone.search_bar',
              value: searchRegion.value,
            ),
            Expanded(
              child: ListView.builder(
                itemCount: searchRegion.value != null && searchRegion.value!.isNotEmpty
                    ? filteredTimezones().length
                    : timezones.value.length,
                itemBuilder: (context, index) {
                  final timezone = searchRegion.value != null && searchRegion.value!.isNotEmpty
                      ? filteredTimezones()[index]
                      : timezones.value[index];
                  return renderItem(context, timezone);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Map<String, dynamic> getStyleSheet(ThemeData theme) {
  return {
    'flexGrow': {
      'flexGrow': 1,
    },
    'container': {
      'flex': 1,
      'backgroundColor': theme.backgroundColor,
    },
    'searchBarInput': {
      'color': theme.textColor,
      'fontSize': 14.0,
    },
    'searchBarInputContainerStyle': {
      'backgroundColor': changeOpacity(theme.centerChannelColor, 0.08),
      'height': 38.0,
    },
    'searchBarContainerStyle': {
      'paddingHorizontal': 12.0,
      'marginBottom': 32.0,
      'marginTop': 12.0,
    },
  };
}
