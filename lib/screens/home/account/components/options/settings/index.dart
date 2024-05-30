import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:mattermost_flutter/components/option_item.dart';
import 'package:mattermost_flutter/utils/tap.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Settings extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final intl = AppLocalizations.of(context)!;

    final openSettings = useCallback(() {
      preventDoubleTap(() {
        showModal(
          context,
          Screens.settings,
          intl.mobileScreenSettings,
        );
      });
    }, []);

    return OptionItem(
      action: openSettings,
      icon: Icons.settings_outlined,
      label: intl.accountSettings,
      testID: 'account.settings.option',
      type: 'default',
    );
  }
}
