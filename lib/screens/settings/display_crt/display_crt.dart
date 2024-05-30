// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:mattermost_flutter/components/settings/block.dart';
import 'package:mattermost_flutter/components/settings/container.dart';
import 'package:mattermost_flutter/components/settings/option.dart';
import 'package:mattermost_flutter/components/settings/separator.dart';
import 'package:mattermost_flutter/context/server.dart';
import 'package:mattermost_flutter/hooks/navigate_back.dart';
import 'package:mattermost_flutter/i18n/i18n.dart';
import 'package:mattermost_flutter/store/ephemeral_store.dart';
import 'package:mattermost_flutter/actions/remote/preference.dart';
import 'package:mattermost_flutter/types/screens/navigation.dart';

class DisplayCRT extends HookWidget {
  final AvailableScreens componentId;
  final String currentUserId;
  final bool isCRTEnabled;

  DisplayCRT({
    required this.componentId,
    required this.currentUserId,
    required this.isCRTEnabled,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = useState(isCRTEnabled);
    final serverUrl = useServerUrl();
    final intl = AppLocalizations.of(context)!;

    final close = () => popTopScreen(componentId);

    final saveCRTPreference = useCallback(() async {
      close();
      if (isCRTEnabled != isEnabled.value) {
        final crtPreference = {
          'category': Preferences.CATEGORIES.DISPLAY_SETTINGS,
          'name': Preferences.COLLAPSED_REPLY_THREADS,
          'user_id': currentUserId,
          'value': isEnabled.value ? Preferences.COLLAPSED_REPLY_THREADS_ON : Preferences.COLLAPSED_REPLY_THREADS_OFF,
        };

        EphemeralStore.setEnablingCRT(true);
        final error = await savePreference(serverUrl, [crtPreference]);
        if (error == null) {
          handleCRTToggled(serverUrl);
        }
      }
    }, [isEnabled.value, isCRTEnabled, serverUrl]);

    useBackNavigation(saveCRTPreference);
    useAndroidHardwareBackHandler(componentId, saveCRTPreference);

    return SettingContainer(
      testID: 'crt_display_settings',
      child: SettingBlock(
        footerText: Text(
          intl.settings_display_crt_desc,
          style: Theme.of(context).textTheme.bodyText2,
        ),
        children: [
          SettingOption(
            action: (value) => isEnabled.value = value,
            label: intl.settings_display_crt_label,
            selected: isEnabled.value,
            testID: 'settings_display.crt.toggle',
            type: SettingOptionType.toggle,
          ),
          SettingSeparator(),
        ],
      ),
    );
  }
}
