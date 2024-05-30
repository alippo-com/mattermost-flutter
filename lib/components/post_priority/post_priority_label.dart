import 'package:flutter/material.dart';
import 'package:mattermost_flutter/components/compass_icon.dart';
import 'package:mattermost_flutter/utils/typography.dart';
import 'package:intl/intl.dart';

class PostPriorityLabel extends StatelessWidget {
  final String label;

  PostPriorityLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    var intl = Intl.message;
    List<BoxDecoration> containerStyle = [
      BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: Colors.transparent,
      ),
    ];

    String iconName = '';
    String labelText = '';
    if (label == PostPriorityType.URGENT) {
      containerStyle.add(BoxDecoration(color: PostPriorityColors.URGENT));
      iconName = 'alert-outline';
      labelText = intl('URGENT', name: 'post_priority.label.urgent', desc: 'Urgent priority label');
    } else if (label == PostPriorityType.IMPORTANT) {
      containerStyle.add(BoxDecoration(color: PostPriorityColors.IMPORTANT));
      iconName = 'alert-circle-outline';
      labelText = intl('IMPORTANT', name: 'post_priority.label.important', desc: 'Important priority label');
    }

    return Container(
      decoration: containerStyle.reduce((value, element) => value..addAll(element)),
      padding: EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CompassIcon(
            name: iconName,
            size: 12,
            color: Colors.white,
            margin: EdgeInsets.only(right: 4),
          ),
          Text(
            labelText,
            style: typography('Body', 25, 'SemiBold').copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
