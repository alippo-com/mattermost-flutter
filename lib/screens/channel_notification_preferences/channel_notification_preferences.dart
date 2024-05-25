import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:reanimated/reanimated.dart';
import 'package:mattermost_flutter/actions/remote/channel.dart';
import 'package:mattermost_flutter/components/settings_container.dart';
import 'package:mattermost_flutter/constants.dart';
import 'package:mattermost_flutter/context/server.dart';
import 'package:mattermost_flutter/hooks/android_back_handler.dart';
import 'package:mattermost_flutter/hooks/did_update.dart';
import 'package:mattermost_flutter/hooks/navigate_back.dart';
import 'package:mattermost_flutter/utils/channel.dart';
import 'package:mattermost_flutter/screens/navigation.dart';
import 'muted_banner.dart';
import 'notify_about.dart';
import 'reset.dart';
import 'thread_replies.dart';
import 'package:mattermost_flutter/types/screens/navigation.dart';

class ChannelNotificationPreferences extends StatefulWidget {
  final String channelId;
  final AvailableScreens componentId;
  final NotificationLevel defaultLevel;
  final String defaultThreadReplies;
  final bool isCRTEnabled;
  final bool isMuted;
  final NotificationLevel notifyLevel;
  final String? notifyThreadReplies;
  final ChannelType channelType;
  final bool hasGMasDMFeature;

  ChannelNotificationPreferences({
    required this.channelId,
    required this.componentId,
    required this.defaultLevel,
    required this.defaultThreadReplies,
    required this.isCRTEnabled,
    required this.isMuted,
    required this.notifyLevel,
    this.notifyThreadReplies,
    required this.channelType,
    required this.hasGMasDMFeature,
  });

  @override
  _ChannelNotificationPreferencesState createState() => _ChannelNotificationPreferencesState();
}

class _ChannelNotificationPreferencesState extends State<ChannelNotificationPreferences> {
  late final serverUrl = Provider.of<ServerUrl>(context, listen: false);
  late final AnimationController _notifyTitleTopController;
  late bool _threadReplies;
  late NotificationLevel _notifyAbout;
  late bool _resetDefaultVisible;

  @override
  void initState() {
    super.initState();

    final defaultNotificationReplies = widget.defaultThreadReplies == 'all';
    final diffNotificationLevel = widget.notifyLevel != NotificationLevel.DEFAULT && widget.notifyLevel != widget.defaultLevel;
    _notifyTitleTopController = AnimationController(vsync: this, value: (widget.isMuted ? MutedBanner.HEIGHT : 0) + NotifyAbout.HEIGHT);
    _notifyAbout = widget.notifyLevel == NotificationLevel.DEFAULT ? widget.defaultLevel : widget.notifyLevel;
    _threadReplies = (widget.notifyThreadReplies ?? widget.defaultThreadReplies) == 'all';
    _resetDefaultVisible = diffNotificationLevel || defaultNotificationReplies != _threadReplies;

    didUpdate(() {
      setState(() {
        // Equivalent to LayoutAnimation in Flutter
      });
    }, [widget.isMuted]);
  }

  void onResetPressed() {
    setState(() {
      _resetDefaultVisible = false;
      _notifyAbout = widget.defaultLevel;
      _threadReplies = widget.defaultThreadReplies == 'all';
    });
  }

  void onNotificationLevel(NotificationLevel level) {
    setState(() {
      _notifyAbout = level;
      _resetDefaultVisible = level != widget.defaultLevel || widget.defaultThreadReplies == 'all' != _threadReplies;
    });
  }

  void onSetThreadReplies(bool value) {
    setState(() {
      _threadReplies = value;
      _resetDefaultVisible = widget.defaultThreadReplies == 'all' != value || _notifyAbout != widget.defaultLevel;
    });
  }

  void save() {
    final pushThreads = _threadReplies ? 'all' : 'mention';

    var notifyAboutToUse = _notifyAbout;
    if (_notifyAbout == widget.defaultLevel) {
      notifyAboutToUse = NotificationLevel.DEFAULT;
    }

    if (widget.notifyLevel != notifyAboutToUse || (widget.isCRTEnabled && pushThreads != widget.notifyThreadReplies)) {
      final props = <String, dynamic>{'push': notifyAboutToUse};
      if (widget.isCRTEnabled) {
        props['push_threads'] = pushThreads;
      }

      updateChannelNotifyProps(serverUrl, widget.channelId, props);
    }
    popTopScreen(widget.componentId);
  }

  @override
  Widget build(BuildContext context) {
    final showThreadReplies = widget.isCRTEnabled &&
        (!widget.hasGMasDMFeature || !isTypeDMorGM(widget.channelType));
    return SettingsContainer(
      testID: 'push_notification_settings',
      children: [
        if (widget.isMuted) MutedBanner(channelId: widget.channelId),
        if (_resetDefaultVisible)
          ResetToDefault(
            onPress: onResetPressed,
            topPosition: _notifyTitleTopController.value,
          ),
        NotifyAbout(
          defaultLevel: widget.defaultLevel,
          isMuted: widget.isMuted,
          notifyLevel: _notifyAbout,
          notifyTitleTop: _notifyTitleTopController.value,
          onPress: onNotificationLevel,
        ),
        if (showThreadReplies)
          ThreadReplies(
            isSelected: _threadReplies,
            onPress: onSetThreadReplies,
            notifyLevel: _notifyAbout,
          ),
      ],
    );
  }

  @override
  void dispose() {
    _notifyTitleTopController.dispose();
    super.dispose();
  }
}
