// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';

class AutocompleteDefaultAnimatedValues extends StatefulWidget {
  final double position;
  final double availableSpace;

  const AutocompleteDefaultAnimatedValues({
    Key? key,
    required this.position,
    required this.availableSpace,
  }) : super(key: key);

  @override
  _AutocompleteDefaultAnimatedValuesState createState() => _AutocompleteDefaultAnimatedValuesState();
}

class _AutocompleteDefaultAnimatedValuesState extends State<AutocompleteDefaultAnimatedValues> with SingleTickerProviderStateMixin {
  late AnimationController _positionController;
  late AnimationController _availableSpaceController;
  late Animation<double> _positionAnimation;
  late Animation<double> _availableSpaceAnimation;

  @override
  void initState() {
    super.initState();

    _positionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _availableSpaceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _positionAnimation = Tween<double>(begin: widget.position, end: widget.position).animate(_positionController);
    _availableSpaceAnimation = Tween<double>(begin: widget.availableSpace, end: widget.availableSpace).animate(_availableSpaceController);

    _positionController.forward();
    _availableSpaceController.forward();
  }

  @override
  void didUpdateWidget(covariant AutocompleteDefaultAnimatedValues oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.position != widget.position) {
      _positionAnimation = Tween<double>(begin: oldWidget.position, end: widget.position).animate(_positionController);
      _positionController.forward(from: 0.0);
    }

    if (oldWidget.availableSpace != widget.availableSpace) {
      _availableSpaceAnimation = Tween<double>(begin: oldWidget.availableSpace, end: widget.availableSpace).animate(_availableSpaceController);
      _availableSpaceController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _positionController.dispose();
    _availableSpaceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(); // Update this with the actual widget tree as needed
  }
}
