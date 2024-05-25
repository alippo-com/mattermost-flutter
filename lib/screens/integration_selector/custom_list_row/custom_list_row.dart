// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:mattermost_flutter/components/compass_icon.dart';

class CustomListRow extends StatelessWidget {
  final String id;
  final VoidCallback? onPress;
  final bool enabled;
  final bool selectable;
  final bool selected;
  final Widget children;
  final String? testID;

  const CustomListRow({
    Key? key,
    required this.id,
    this.onPress,
    required this.enabled,
    required this.selectable,
    required this.selected,
    required this.children,
    this.testID,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPress,
      child: Container(
        height: 65,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        alignment: Alignment.center,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (selectable)
              Container(
                height: 50,
                alignment: Alignment.center,
                child: Container(
                  height: 28,
                  width: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selected ? Color(0xFF166DE0) : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: enabled
                          ? Color(0xFF3D3C40).withOpacity(0.32)
                          : Color(0xFF3D3C40).withOpacity(0.16),
                      width: selected ? 0 : 1,
                    ),
                  ),
                  child: selected
                      ? CompassIcon(
                          name: 'check',
                          size: 24,
                          color: Colors.white,
                        )
                      : null,
                ),
              ),
            Expanded(
              child: children,
            ),
          ],
        ),
      ),
    );
  }
}
