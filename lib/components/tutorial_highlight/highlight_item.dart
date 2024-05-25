
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/svg.dart';
import 'package:tinycolor2/tinycolor2.dart';

class HighlightItem extends StatelessWidget {
  final double height;
  final TutorialItemBounds itemBounds;
  final VoidCallback onDismiss;
  final VoidCallback onLayout;
  final double width;
  final double borderRadius;

  const HighlightItem({
    Key? key,
    required this.height,
    required this.itemBounds,
    required this.onDismiss,
    required this.onLayout,
    this.borderRadius = 0,
    required this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = useTheme(context);
    final isDark = TinyColor(theme.centerChannelBg).isDark();

    final parent = Rect.fromLTWH(0, 0, width, height);
    final pathD = constructRectangularPathWithBorderRadius(
      parent, itemBounds, borderRadius);

    return GestureDetector(
      onTap: onDismiss,
      onLayout: (details) => onLayout(),
      child: Stack(
        children: [
          Positioned.fill(
            child: SvgPicture.string(
              '''
              <svg>
                <defs>
                  <clipPath id="elementBounds">
                    <path d="$pathD" clip-rule="evenodd" />
                  </clipPath>
                </defs>
                <rect
                  x="0"
                  y="0"
                  width="$width"
                  height="$height"
                  clip-path="url(#elementBounds)"
                  fill="${isDark ? 'white' : 'black'}"
                  fill-opacity="0.3"
                />
              </svg>
              ''',
              allowDrawingOutsideViewBox: true,
            ),
          ),
        ],
      ),
    );
  }
}
