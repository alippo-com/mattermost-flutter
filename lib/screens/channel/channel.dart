import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:mattermost_flutter/components/floating_call_container.dart';
import 'package:mattermost_flutter/components/post_draft.dart';
import 'package:mattermost_flutter/constants.dart';
import 'package:mattermost_flutter/hooks/channel_switch.dart';
import 'package:mattermost_flutter/hooks/header.dart';
import 'package:mattermost_flutter/hooks/team_switch.dart';
import 'package:mattermost_flutter/store/ephemeral_store.dart';
import 'package:mattermost_flutter/types/screens/navigation.dart';
import 'package:mattermost_flutter/types/database/models/servers/preference.dart';

import 'channel_post_list.dart';
import 'header.dart';
import 'use_gm_as_dm_notice.dart';

class Channel extends HookWidget {
  final String channelId;
  final AvailableScreens? componentId;
  final bool showJoinCallBanner;
  final bool isInACall;
  final bool isCallsEnabledInChannel;
  final bool showIncomingCalls;
  final bool? isTabletView;
  final List<PreferenceModel> dismissedGMasDMNotice;
  final String currentUserId;
  final ChannelType channelType;
  final bool hasGMasDMFeature;

  const Channel({
    required this.channelId,
    this.componentId,
    required this.showJoinCallBanner,
    required this.isInACall,
    required this.isCallsEnabledInChannel,
    required this.showIncomingCalls,
    this.isTabletView,
    required this.dismissedGMasDMNotice,
    required this.currentUserId,
    required this.channelType,
    required this.hasGMasDMFeature,
  });

  @override
  Widget build(BuildContext context) {
    useGMasDMNotice(currentUserId, channelType, dismissedGMasDMNotice, hasGMasDMFeature);
    final isTablet = useIsTablet();
    final insets = MediaQuery.of(context).viewInsets;
    final shouldRenderPosts = useState(false);
    final switchingTeam = useTeamSwitch();
    final switchingChannels = useChannelSwitch();
    final defaultHeight = useDefaultHeaderHeight();
    final postDraftRef = useRef(null);
    final containerHeight = useState(0.0);
    final shouldRender = !switchingTeam && !switchingChannels && shouldRenderPosts.value && channelId.isNotEmpty;

    void handleBack() {
      popTopScreen(componentId);
    }

    useKeyboardTrackingPaused(postDraftRef, channelId, trackKeyboardForScreens);
    useAndroidHardwareBackHandler(componentId, handleBack);

    final marginTop = defaultHeight + (isTablet ? 0 : -insets.top);
    useEffect(() {
      final raf = requestAnimationFrame(() {
        shouldRenderPosts.value = channelId.isNotEmpty;
      });

      final t = setTimeout(() {
        EphemeralStore.removeSwitchingToChannel(channelId);
      }, 500);

      storeLastViewedChannelIdAndServer(channelId);

      return () {
        cancelAnimationFrame(raf);
        clearTimeout(t);
        removeLastViewedChannelIdAndServer();
        EphemeralStore.removeSwitchingToChannel(channelId);
      };
    }, [channelId]);

    void onLayout(e) {
      containerHeight.value = e.size.height;
    }

    final showFloatingCallContainer = showJoinCallBanner || isInACall || showIncomingCalls;

    return FreezeScreen(
      child: SafeArea(
        child: Column(
          children: [
            if (shouldRender)
              Expanded(
                child: Column(
                  children: [
                    SizedBox(height: marginTop),
                    ChannelPostList(channelId: channelId),
                  ],
                ),
              ),
            PostDraft(
              channelId: channelId,
              keyboardTracker: postDraftRef,
              scrollViewNativeID: channelId,
              accessoriesContainerID: ACCESSORIES_CONTAINER_NATIVE_ID,
              containerHeight: containerHeight.value,
              isChannelScreen: true,
              canShowPostPriority: true,
            ),
            if (showFloatingCallContainer)
              FloatingCallContainer(
                channelId: channelId,
                showJoinCallBanner: showJoinCallBanner,
                showIncomingCalls: showIncomingCalls,
                isInACall: isInACall,
              ),
          ],
        ),
      ),
    );
  }
}
