
// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:mattermost_flutter/types.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_reactive_hooks/flutter_reactive_hooks.dart';
import 'package:mattermost_flutter/utils/styles.dart';

class ProgressBar extends HookWidget {
  final Color color;
  final double progress;
  final BoxDecoration? style;

  ProgressBar({
    required this.color,
    required this.progress,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final width = useState<double>(0.0);
    final progressValue = useSharedValue(progress);

    final progressAnimatedStyle = useAnimatedStyle(() {
      return {
        'transform': [
          {'translateX': withTiming(((progressValue.value * 0.5) - 0.5) * width.value, duration: Duration(milliseconds: 200))},
          {'scaleX': withTiming(progressValue.value != 0 ? progressValue.value : 0.0001, duration: Duration(milliseconds: 200))},
        ],
      };
    }, [width.value]);

    useEffect(() {
      progressValue.value = progress;
    }, [progress]);

    return LayoutBuilder(
      builder: (context, constraints) {
        width.value = constraints.maxWidth;
        return Container(
          height: 4,
          decoration: style ?? BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            color: Color.fromRGBO(255, 255, 255, 0.16),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: Align(
              alignment: Alignment.centerLeft,
              child: AnimatedBuilder(
                animation: progressAnimatedStyle,
                builder: (context, child) {
                  return Container(
                    width: width.value,
                    decoration: BoxDecoration(
                      color: color,
                    ),
                    transform: progressAnimatedStyle['transform'],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
