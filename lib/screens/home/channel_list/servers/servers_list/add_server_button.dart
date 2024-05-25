import 'package:flutter/material.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/screens/bottom_sheet/bottom_sheet_button.dart';
import 'package:mattermost_flutter/utils/server.dart';

class AddServerButton extends StatelessWidget {
  final Function onDismiss;

  AddServerButton({required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    final theme = useTheme();
    final localizations = Localizations.of<AppLocalizations>(context, AppLocalizations);

    void onAddServer() {
      addNewServer(theme);
      onDismiss();
    }

    return Container(
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          BottomSheetButton(
            onPressed: onAddServer,
            icon: Icons.add,
            text: localizations?.translate('servers.create_button') ?? 'Add a server',
            testID: 'servers.create_button',
          ),
        ],
      ),
    );
  }
}
