
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:provider/provider.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/utils/tap.dart';
import 'message_box.dart';

class NoCommonTeamForm extends StatelessWidget {
  final ViewStyle containerStyles;

  const NoCommonTeamForm({required this.containerStyles});

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<Theme>(context);
    final formatMessage = FlutterI18n.translate;

    final header = formatMessage(context, 'channel_info.convert_gm_to_channel.warning.no_teams.header', {
      'defaultMessage': 'Unable to convert to a channel because group members are part of different teams',
    });

    final body = formatMessage(context, 'channel_info.convert_gm_to_channel.warning.no_teams.body', {
      'defaultMessage': 'Group Message cannot be converted to a channel because members are not a part of the same team. Add all members to a single team to convert this group message to a channel.',
    });

    final buttonText = formatMessage(context, 'generic.back', {
      'defaultMessage': 'Back',
    });

    return Container(
      style: containerStyles,
      child: Column(
        children: [
          MessageBox(
            header: header,
            body: body,
            type: 'danger',
          ),
          Button(
            onPressed: preventDoubleTap(() {
              popTopScreen(context);
            }),
            text: buttonText,
            theme: theme,
            size: 'lg',
          ),
        ],
      ),
    );
  }
}
