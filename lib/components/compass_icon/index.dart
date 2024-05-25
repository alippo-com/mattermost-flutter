
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

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
