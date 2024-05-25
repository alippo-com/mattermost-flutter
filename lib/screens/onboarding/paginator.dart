// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mattermost_flutter/types/theme.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/components/animated_dot.dart';

class Paginator extends StatelessWidget {
  final int dataLength;
  final Theme theme;
  final ValueNotifier<double> scrollX;
  final Function(int) moveToSlide;

  Paginator({
    required this.dataLength,
    required this.theme,
    required this.scrollX,
    required this.moveToSlide,
  });

  @override
  Widget build(BuildContext context) {
    final styles = getStyleSheet(theme);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(dataLength, (index) {
        return Dot(
          index: index,
          theme: theme,
          scrollX: scrollX,
          moveToSlide: moveToSlide,
        );
      }).toList(),
    );
  }

  Map<String, dynamic> getStyleSheet(Theme theme) {
    const double dotSize = 16;
    const double halfDotSize = dotSize / 2;

    return {
      'dot': BoxDecoration(
        color: theme.buttonBg.withOpacity(0.25),
        borderRadius: BorderRadius.circular(5),
      ),
      'fixedDot': BoxDecoration(
        color: theme.buttonBg.withOpacity(0.25),
        borderRadius: BorderRadius.circular(5),
      ),
      'outerDot': BoxDecoration(
        color: theme.buttonBg.withOpacity(0.15),
        borderRadius: BorderRadius.circular(dotSize / 2),
      ),
      'paginatorContainer': BoxDecoration(
        borderRadius: BorderRadius.circular(5),
      ),
    };
  }
}

class Dot extends StatelessWidget {
  final int index;
  final ValueNotifier<double> scrollX;
  final Theme theme;
  final Function(int) moveToSlide;

  Dot({
    required this.index,
    required this.scrollX,
    required this.theme,
    required this.moveToSlide,
  });

  @override
  Widget build(BuildContext context) {
    final styles = getStyleSheet(theme);

    return GestureDetector(
      onTap: () => moveToSlide(index),
      child: Stack(
        children: [
          Container(
            decoration: styles['fixedDot'],
            width: 8,
            height: 8,
          ),
          AnimatedBuilder(
            animation: scrollX,
            builder: (context, child) {
              return Opacity(
                opacity: _getOpacity(scrollX.value, index),
                child: Container(
                  decoration: styles['outerDot'],
                  width: 16,
                  height: 16,
                ),
              );
            },
          ),
          AnimatedBuilder(
            animation: scrollX,
            builder: (context, child) {
              return Opacity(
                opacity: _getOpacity(scrollX.value, index),
                child: Container(
                  decoration: styles['dot'],
                  width: 8,
                  height: 8,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  double _getOpacity(double scrollX, int index) {
    final double width = MediaQuery.of(context).size.width;
    final double inputRangeStart = (index - 1) * width;
    final double inputRangeEnd = (index + 1) * width;

    if (scrollX >= inputRangeStart && scrollX <= inputRangeEnd) {
      return 1.0;
    } else {
      return 0.0;
    }
  }

  Map<String, dynamic> getStyleSheet(Theme theme) {
    const double dotSize = 16;
    const double halfDotSize = dotSize / 2;

    return {
      'dot': BoxDecoration(
        color: theme.buttonBg.withOpacity(0.25),
        borderRadius: BorderRadius.circular(5),
      ),
      'fixedDot': BoxDecoration(
        color: theme.buttonBg.withOpacity(0.25),
        borderRadius: BorderRadius.circular(5),
      ),
      'outerDot': BoxDecoration(
        color: theme.buttonBg.withOpacity(0.15),
        borderRadius: BorderRadius.circular(dotSize / 2),
      ),
      'paginatorContainer': BoxDecoration(
        borderRadius: BorderRadius.circular(5),
      ),
    };
  }
}
