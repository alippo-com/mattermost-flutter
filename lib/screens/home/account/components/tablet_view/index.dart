import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mattermost_flutter/constants/events.dart';
import 'package:mattermost_flutter/screens/custom_status.dart';
import 'package:mattermost_flutter/screens/edit_profile.dart';

class SelectedView {
  final String id;
  final Widget component;

  SelectedView({required this.id, required this.component});
}

class AccountTabletView extends StatefulWidget {
  @override
  _AccountTabletViewState createState() => _AccountTabletViewState();
}

class _AccountTabletViewState extends State<AccountTabletView> {
  SelectedView? selected;

  @override
  void initState() {
    super.initState();
    _initListener();
  }

  void _initListener() {
    const EventChannel eventChannel = EventChannel(Events.ACCOUNT_SELECT_TABLET_VIEW);
    eventChannel.receiveBroadcastStream().listen((dynamic id) {
      final component = _getComponentById(id);
      if (component != null) {
        setState(() {
          selected = SelectedView(id: id, component: component);
        });
      }
    });
  }

  Widget? _getComponentById(String id) {
    switch (id) {
      case Screens.CUSTOM_STATUS:
        return CustomStatus();
      case Screens.EDIT_PROFILE:
        return EditProfile();
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (selected == null) {
      return Container();
    }

    return selected!.component;
  }
}
