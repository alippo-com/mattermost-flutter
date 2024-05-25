
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mattermost_flutter/components/option_item.dart';
import 'package:mattermost_flutter/context/server.dart';
import 'package:mattermost_flutter/utils/draft.dart';
import 'package:mattermost_flutter/utils/tap.dart';

class IgnoreMentions extends StatefulWidget {
  final String channelId;
  final bool ignoring;
  final String displayName;

  IgnoreMentions({
    required this.channelId,
    required this.ignoring,
    required this.displayName,
  });

  @override
  _IgnoreMentionsState createState() => _IgnoreMentionsState();
}

class _IgnoreMentionsState extends State<IgnoreMentions> {
  late bool ignored;

  @override
  void initState() {
    super.initState();
    ignored = widget.ignoring;
  }

  Future<void> toggleIgnore() async {
    final serverUrl = useServerUrl();
    final intl = AppLocalizations.of(context)!;
    final props = {
      'ignore_channel_mentions': widget.ignoring ? 'off' : 'on',
    };
    
    setState(() {
      ignored = !ignored;
    });

    final result = await updateChannelNotifyProps(serverUrl, widget.channelId, props);
    if (result?.error != null) {
      alertErrorWithFallback(
        intl,
        result.error,
        AppLocalizations.of(context)!.channelInfoChannelAutoFollowThreadsFailed(widget.displayName),
        {'displayName': widget.displayName},
      );
      setState(() {
        ignored = !ignored;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return OptionItem(
      action: preventDoubleTap(toggleIgnore),
      label: AppLocalizations.of(context)!.channelInfoIgnoreMentions,
      icon: Icons.alternate_email,
      type: 'toggle',
      selected: ignored,
      testID: 'channel_info.options.ignore_mentions.option.toggled.\$ignored',
    );
  }
}
