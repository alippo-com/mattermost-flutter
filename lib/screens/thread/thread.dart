// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:unique_id/unique_id.dart';
import 'package:mattermost_flutter/actions/app/global.dart';
import 'package:mattermost_flutter/calls/components/floating_call_container.dart';
import 'package:mattermost_flutter/components/freeze_screen.dart';
import 'package:mattermost_flutter/components/post_draft.dart';
import 'package:mattermost_flutter/components/rounded_header_context.dart';
import 'package:mattermost_flutter/constants.dart';
import 'package:mattermost_flutter/hooks/android_back_handler.dart';
import 'package:mattermost_flutter/hooks/did_update.dart';
import 'package:mattermost_flutter/hooks/keyboard_tracking.dart';
import 'package:mattermost_flutter/screens/navigation.dart';
import 'package:mattermost_flutter/store/ephemeral_store.dart';
import 'package:mattermost_flutter/store/navigation_store.dart';
import 'package:mattermost_flutter/types.dart';
import 'package:mattermost_flutter/screens/thread/thread_post_list.dart';

class Thread extends StatefulWidget {
  final AvailableScreens componentId;
  final bool isCRTEnabled;
  final bool showJoinCallBanner;
  final bool isInACall;
  final bool showIncomingCalls;
  final String rootId;
  final PostModel? rootPost;

  const Thread({
    required this.componentId,
    required this.isCRTEnabled,
    required this.rootId,
    this.rootPost,
    required this.showJoinCallBanner,
    required this.isInACall,
    required this.showIncomingCalls,
    Key? key,
  }) : super(key: key);

  @override
  _ThreadState createState() => _ThreadState();
}

class _ThreadState extends State<Thread> {
  final GlobalKey<KeyboardTrackingViewState> postDraftKey = GlobalKey();
  double containerHeight = 0;

  @override
  void initState() {
    super.initState();
    useKeyboardTrackingPaused(postDraftKey, widget.rootId, [Screens.THREAD]);
    useAndroidHardwareBackHandler(widget.componentId, _close);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.isCRTEnabled && widget.rootId.isNotEmpty) {
        final id = '${widget.componentId}-${widget.rootId}-${uniqueId()}';
        final name = Screens.THREAD_FOLLOW_BUTTON;
        setButtons(widget.componentId, rightButtons: [
          NavigationButton(
            id: id,
            component: NavigationComponent(
              name: name,
              passProps: {'threadId': widget.rootId},
            ),
          ),
        ]);
      } else {
        setButtons(widget.componentId, rightButtons: []);
      }
    });

    if (widget.isCRTEnabled &&
        (NavigationStore.getScreensInStack()[1] == Screens.GLOBAL_THREADS ||
            NavigationStore.getScreensInStack()[1] == Screens.HOME)) {
      storeLastViewedThreadIdAndServer(widget.rootId);
    }
  }

  @override
  void dispose() {
    if (widget.isCRTEnabled) {
      removeLastViewedThreadIdAndServer();
    }
    if (widget.rootId == EphemeralStore.getCurrentThreadId()) {
      EphemeralStore.setCurrentThreadId('');
    }
    setButtons(widget.componentId, rightButtons: []);
    super.dispose();
  }

  _close() {
    popTopScreen(widget.componentId);
  }

  @override
  void didUpdateWidget(covariant Thread oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.rootPost == null) {
      _close();
    }
  }

  _onLayout(BoxConstraints constraints) {
    setState(() {
      containerHeight = constraints.maxHeight;
    });
  }

  @override
  Widget build(BuildContext context) {
    final showFloatingCallContainer = widget.showJoinCallBanner ||
        widget.isInACall ||
        widget.showIncomingCalls;

    return FreezeScreen(
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            _onLayout(constraints);
            return Column(
              children: [
                RoundedHeaderContext(),
                if (widget.rootPost != null) ...[
                  Expanded(
                    child: ThreadPostList(
                      nativeID: widget.rootId,
                      rootPost: widget.rootPost!,
                    ),
                  ),
                  PostDraft(
                    channelId: widget.rootPost!.channelId,
                    scrollViewNativeID: widget.rootId,
                    accessoriesContainerID: THREAD_ACCESSORIES_CONTAINER_NATIVE_ID,
                    rootId: widget.rootId,
                    keyboardTracker: postDraftKey,
                    containerHeight: containerHeight,
                    isChannelScreen: false,
                  ),
                ],
                if (showFloatingCallContainer)
                  FloatingCallContainer(
                    channelId: widget.rootPost!.channelId,
                    showJoinCallBanner: widget.showJoinCallBanner,
                    showIncomingCalls: widget.showIncomingCalls,
                    isInACall: widget.isInACall,
                    threadScreen: true,
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
