
import 'package:flutter/material.dart';
import 'package:flutter_safe_area/flutter_safe_area.dart';
import 'package:mattermost_flutter/constants/view.dart';
import 'package:mattermost_flutter/context/server.dart';
import 'package:mattermost_flutter/calls/components/current_call_bar.dart';
import 'package:mattermost_flutter/calls/components/incoming_calls_container.dart';
import 'package:mattermost_flutter/calls/components/join_call_banner.dart';

class FloatingCallContainer extends StatelessWidget {
  final String? channelId;
  final bool? showJoinCallBanner;
  final bool? showIncomingCalls;
  final bool? isInACall;
  final bool? threadScreen;
  final bool? channelsScreen;

  const FloatingCallContainer({
    Key? key,
    this.channelId,
    this.showJoinCallBanner,
    this.showIncomingCalls,
    this.isInACall,
    this.threadScreen,
    this.channelsScreen,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final serverUrl = useServerUrl();
    final insets = MediaQuery.of(context).padding;
    final isTablet = useIsTablet(context);

    final topBarForTablet = (isTablet && !(threadScreen ?? false)) ? TABLET_HEADER_HEIGHT : 0.0;
    final topBarChannel = (!isTablet && !(threadScreen ?? false)) ? DEFAULT_HEADER_HEIGHT : 0.0;
    final wrapperTop = EdgeInsets.only(top: insets.top + topBarForTablet + topBarChannel);
    final wrapperBottom = EdgeInsets.only(bottom: 8.0);

    return Positioned(
      top: channelsScreen ?? false ? null : wrapperTop.top,
      bottom: channelsScreen ?? false ? wrapperBottom.bottom : null,
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: [
          if (showJoinCallBanner ?? false && channelId != null)
            JoinCallBanner(
              serverUrl: serverUrl,
              channelId: channelId!,
            ),
          if (isInACall ?? false) CurrentCallBar(),
          if (showIncomingCalls ?? false && channelId != null)
            IncomingCallsContainer(
              channelId: channelId!,
            ),
        ],
      ),
    );
  }
}
