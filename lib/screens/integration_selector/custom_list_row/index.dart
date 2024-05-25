import 'package:flutter/material.dart';
import 'package:mattermost_flutter/types/compass_icon.dart';

class CustomListRow extends StatelessWidget {
  final String id;
  final void Function()? onPress;
  final bool enabled;
  final bool selectable;
  final bool selected;
  final Widget? children;
  final String? testID;

  const CustomListRow({
    required this.id,
    this.onPress,
    required this.enabled,
    required this.selectable,
    required this.selected,
    this.children,
    this.testID,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPress,
      child: Container(
        height: 65,
        alignment: Alignment.center,
        child: Row(
          children: [
            if (selectable)
              Container(
                height: 50,
                padding: EdgeInsets.only(right: 10),
                alignment: Alignment.center,
                child: Container(
                  height: 28,
                  width: 28,
                  decoration: BoxDecoration(
                    color: selected ? Color(0xFF166DE0) : Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: enabled
                          ? Color(0x003D3C40).withOpacity(0.32)
                          : Color(0x003D3C40).withOpacity(0.16),
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
              child: Row(
                children: [if (children != null) children!],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
