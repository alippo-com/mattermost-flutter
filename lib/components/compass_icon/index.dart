
import 'package:flutter/material.dart';

class CompassIcon extends StatelessWidget {
  final IconData iconData;

  CompassIcon({required this.iconData});

  @override
  Widget build(BuildContext context) {
    return Icon(
      iconData,
      fontFamily: 'CompassIcons',
      fontPackage: 'mattermost_flutter',
    );
  }
}
