
import 'package:flutter/material.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/hooks/device.dart';
import 'package:mattermost_flutter/screens/bottom_sheet/button.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/typography.dart';

const double TITLE_MARGIN_TOP = 4.0;
const double TITLE_MARGIN_BOTTOM = 12.0;

const double TITLE_HEIGHT = TITLE_MARGIN_TOP + TITLE_MARGIN_BOTTOM + 30.0; // typography 600 line height
const double TITLE_SEPARATOR_MARGIN = 12.0;
const double TITLE_SEPARATOR_MARGIN_TABLET = 20.0;

class BottomSheetContent extends StatelessWidget {
  final String? buttonIcon;
  final String? buttonText;
  final Widget children;
  final bool? disableButton;
  final void Function()? onPress;
  final bool showButton;
  final bool showTitle;
  final String? testID;
  final String? title;
  final bool titleSeparator;

  BottomSheetContent({
    this.buttonIcon,
    this.buttonText,
    required this.children,
    this.disableButton,
    this.onPress,
    required this.showButton,
    required this.showTitle,
    this.testID,
    this.title,
    required this.titleSeparator,
  });

  @override
  Widget build(BuildContext context) {
    final dimensions = MediaQuery.of(context).size;
    final theme = useTheme(context);
    final isTablet = useIsTablet(context);
    final styles = _getStyleSheet(theme);
    final separatorWidth = dimensions.width > 450 ? dimensions.width : 450;
    final buttonTestId = '$testID.${buttonText?.replaceAll(' ', '_').toLowerCase()}.button';

    return Container(
      child: Column(
        children: [
          if (showTitle)
            Container(
              margin: EdgeInsets.only(top: TITLE_MARGIN_TOP, bottom: TITLE_MARGIN_BOTTOM),
              child: Text(
                title!,
                style: styles.titleText,
                key: Key('$testID.title'),
              ),
            ),
          if (titleSeparator)
            Container(
              width: separatorWidth,
              height: 1,
              margin: EdgeInsets.only(bottom: isTablet ? TITLE_SEPARATOR_MARGIN_TABLET : TITLE_SEPARATOR_MARGIN),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: changeOpacity(theme.centerChannelColor, 0.08),
                  ),
                ),
              ),
            ),
          children,
          if (showButton)
            Button(
              disabled: disableButton ?? false,
              onPress: onPress,
              icon: buttonIcon,
              key: Key(buttonTestId),
              text: buttonText,
            ),
        ],
      ),
    );
  }

  Map<String, TextStyle> _getStyleSheet(Theme theme) {
    return {
      'titleText': TextStyle(
        color: theme.centerChannelColor,
        fontWeight: FontWeight.w600,
        fontFamily: 'SemiBold',
      ),
    };
  }
}
