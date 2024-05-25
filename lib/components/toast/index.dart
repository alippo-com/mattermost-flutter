
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:mattermost_flutter/components/compass_icon.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/typography.dart';

class Toast extends HookWidget {
  final Animation<Offset> animation;
  final Widget? children;
  final String? iconName;
  final String? message;
  final TextStyle? textStyle;
  final BoxDecoration? boxDecoration;

  Toast({
    required this.animation,
    this.children,
    this.iconName,
    this.message,
    this.textStyle,
    this.boxDecoration,
  });

  static const double toastHeight = 56;
  static const double toastMargin = 40;
  static const double widthTablet = 484;
  static const double widthMobile = 400;

  @override
  Widget build(BuildContext context) {
    final theme = useTheme();
    final dimensions = MediaQuery.of(context).size;
    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;

    final double toastWidth = isTablet ? widthTablet : widthMobile;
    final double width = dimensions.width < dimensions.height
        ? dimensions.width
        : dimensions.height;
    final double adjustedWidth = width - toastMargin;

    return SlideTransition(
      position: animation,
      child: Center(
        child: Container(
          alignment: Alignment.center,
          width: adjustedWidth,
          height: toastHeight,
          decoration: boxDecoration ??
              BoxDecoration(
                color: theme.onlineIndicator,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: changeOpacity(Colors.black, 0.12),
                    offset: Offset(0, 4),
                    blurRadius: 6,
                  ),
                ],
              ),
          child: Row(
            children: [
              if (iconName != null)
                CompassIcon(
                  color: theme.buttonColor,
                  name: iconName!,
                  size: 18,
                  style: textStyle,
                ),
              if (message != null)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text(
                      message!,
                      style: textStyle ??
                          typography(
                            context,
                            'Body',
                            100,
                            FontWeight.w600,
                          ).copyWith(color: theme.buttonColor),
                      key: Key('toast.message'),
                    ),
                  ),
                ),
              if (children != null) children!,
            ],
          ),
        ),
      ),
    );
  }
}
