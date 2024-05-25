// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mattermost_flutter/hooks/device.dart';
import 'package:mattermost_flutter/hooks/freeze.dart';

class FreezePlaceholder extends StatelessWidget {
  final Color backgroundColor;

  FreezePlaceholder({required this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    return Container(color: backgroundColor, width: double.infinity, height: double.infinity);
  }
}

class FreezeScreen extends StatelessWidget {
  final Widget child;
  final bool? freezeFromProps;

  FreezeScreen({required this.child, this.freezeFromProps});

  @override
  Widget build(BuildContext context) {
    final deviceHooks = Provider.of<DeviceHooks>(context);
    final freezeHooks = Provider.of<FreezeHooks>(context);

    final isTablet = deviceHooks.useIsTablet();
    final freeze = freezeHooks.useFreeze();
    final backgroundColor = freezeHooks.backgroundColor;

    final placeholder = FreezePlaceholder(backgroundColor: backgroundColor);

    Widget component = child;
    if (!isTablet) {
      component = Positioned.fill(
        child: child,
      );
    }

    return freezeHooks.Freeze(
      freeze: freezeFromProps ?? freeze,
      placeholder: placeholder,
      child: component,
    );
  }
}
