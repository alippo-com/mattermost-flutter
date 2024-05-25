
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mattermost_flutter/constants/navigation.dart';
import 'package:mattermost_flutter/constants/screens.dart';
import 'package:mattermost_flutter/screens/channel.dart';
import 'package:mattermost_flutter/screens/global_threads.dart';

class SelectedView {
  final String id;
  final Widget component;

  SelectedView({required this.id, required this.component});
}

class AdditionalTabletView extends StatefulWidget {
  final bool onTeam;
  final String currentChannelId;
  final bool isCRTEnabled;

  AdditionalTabletView({
    required this.onTeam,
    required this.currentChannelId,
    required this.isCRTEnabled,
  });

  @override
  _AdditionalTabletViewState createState() => _AdditionalTabletViewState();
}

class _AdditionalTabletViewState extends State<AdditionalTabletView> {
  late SelectedView selected;
  bool initialLoad = true;
  static const Map<String, Widget> componentsList = {
    Screens.CHANNEL: Channel(),
    Screens.GLOBAL_THREADS: GlobalThreads(),
  };
  static const SelectedView channelScreen = SelectedView(id: Screens.CHANNEL, component: Channel());
  static const SelectedView globalScreen = SelectedView(id: Screens.GLOBAL_THREADS, component: GlobalThreads());

  @override
  void initState() {
    super.initState();
    selected = widget.isCRTEnabled && widget.currentChannelId.isEmpty ? globalScreen : channelScreen;

    DeviceEventEmitter.on(Navigation.NAVIGATION_HOME, (id) {
      final component = componentsList[id];
      if (component != null) {
        setState(() {
          selected = SelectedView(id: id, component: component);
        });
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        initialLoad = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.onTeam || initialLoad) {
      return Container();
    }

    return selected.component;
  }
}
