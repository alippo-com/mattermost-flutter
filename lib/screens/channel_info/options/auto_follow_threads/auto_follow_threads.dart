
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mattermost_flutter/components/option_item.dart';
import 'package:mattermost_flutter/constants/channel.dart';
import 'package:mattermost_flutter/utils/alert.dart';
import 'package:mattermost_flutter/utils/navigation.dart';
import 'package:mattermost_flutter/utils/tap.dart';
import 'package:mattermost_flutter/context/server.dart';
import 'package:mattermost_flutter/actions/remote/channel.dart';

class AutoFollowThreads extends StatefulWidget {
  final String channelId;
  final bool followedStatus;
  final String displayName;

  AutoFollowThreads({
    required this.channelId,
    required this.followedStatus,
    required this.displayName,
  });

  @override
  _AutoFollowThreadsState createState() => _AutoFollowThreadsState();
}

class _AutoFollowThreadsState extends State<AutoFollowThreads> {
  late bool autoFollow;

  @override
  void initState() {
    super.initState();
    autoFollow = widget.followedStatus;
  }

  void toggleFollow() {
    preventDoubleTap(() async {
      final props = {
        'channel_auto_follow_threads': widget.followedStatus
            ? CHANNEL_AUTO_FOLLOW_THREADS_FALSE
            : CHANNEL_AUTO_FOLLOW_THREADS_TRUE,
      };
      setState(() {
        autoFollow = !autoFollow;
      });
      final result = await updateChannelNotifyProps(widget.channelId, props);
      if (result.error != null) {
        alertErrorWithFallback(
          context,
          result.error,
          AppLocalizations.of(context).channelInfoChannelAutoFollowThreadsFailed,
          {'displayName': widget.displayName},
        );
        setState(() {
          autoFollow = !autoFollow;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return OptionItem(
      action: toggleFollow,
      label: AppLocalizations.of(context)
          .channelInfoChannelAutoFollowThreads,
      icon: Icons.message,
      type: 'toggle',
      selected: autoFollow,
      testID:
          'channel_info.options.channel_auto_follow_threads.option.toggled.$autoFollow',
    );
  }
}

class EnhancedAutoFollowThreads extends StatelessWidget {
  final String channelId;
  final Database database;

  EnhancedAutoFollowThreads({
    required this.channelId,
    required this.database,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: observeChannelSettings(database, channelId).pipe(
        switchMap((settings) {
          return of$(settings?.notifyProps?.channel_auto_follow_threads == Channel.CHANNEL_AUTO_FOLLOW_THREADS_TRUE);
        }),
      ),
      builder: (context, snapshot) {
        final followedStatus = snapshot.data ?? false;
        return AutoFollowThreads(
          channelId: channelId,
          followedStatus: followedStatus,
          displayName: observeChannel(database, channelId).pipe(
            switchMap((channel) => of$(channel?.displayName)),
          ),
        );
      },
    );
  }
}
