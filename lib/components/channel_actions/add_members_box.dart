import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mattermost_flutter/components/option_box.dart';
import 'package:mattermost_flutter/utils/navigation.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AddMembersBox extends StatelessWidget {
  final String channelId;
  final String displayName;
  final bool? inModal;
  final BoxDecoration? containerStyle;
  final String testID;

  AddMembersBox({
    required this.channelId,
    required this.displayName,
    this.inModal,
    this.containerStyle,
    required this.testID,
  });

  @override
  Widget build(BuildContext context) {
    final intl = AppLocalizations.of(context)!;
    final theme = Provider.of<ThemeNotifier>(context).currentTheme;

    Future<void> onAddMembers() async {
      final title = intl.introAddMembers;
      final options = await getHeaderOptions(theme, displayName, inModal);
      if (inModal == true) {
        goToScreen(context, Screens.channelAddMembers, title, {
          'channelId': channelId,
          'inModal': inModal,
        }, options);
        return;
      }

      await dismissBottomSheet(context);
      showModal(context, Screens.channelAddMembers, title, {
        'channelId': channelId,
        'inModal': inModal,
      }, options);
    }

    return OptionBox(
      containerStyle: containerStyle,
      iconName: Icons.person_add,
      onPress: onAddMembers,
      testID: testID,
      text: intl.introAddMembers,
    );
  }
}
