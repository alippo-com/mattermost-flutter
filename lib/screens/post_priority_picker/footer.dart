// Converted from ./mattermost-mobile/app/screens/post_priority_picker/footer.tsx

import 'package:flutter/material.dart';
import 'package:mattermost_flutter/components/formatted_text.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/typography.dart';

class PostPriorityPickerFooter extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback onSubmit;

  const PostPriorityPickerFooter({
    Key? key,
    required this.onCancel,
    required this.onSubmit,
  }) : super(key: key);

  double getFooterHeight() {
    const double TEXT_HEIGHT = 24;
    const double BUTTON_PADDING = 15;
    const double FOOTER_PADDING = 20;
    return (FOOTER_PADDING * 2) + (BUTTON_PADDING * 2) + TEXT_HEIGHT;
  }

  @override
  Widget build(BuildContext context) {
    final theme = useTheme(context);
    final isTablet = useIsTablet(context);
    final style = getStyleSheet(theme);

    return Container(
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: 20 + (isTablet ? 12 : 0),
      ),
      decoration: BoxDecoration(
        color: theme.centerChannelBg,
        border: Border(
          top: BorderSide(
            color: changeOpacity(theme.centerChannelColor, 0.16),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: onCancel,
              child: Container(
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  color: changeOpacity(theme.buttonBg, 0.08),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: FormattedText(
                  id: 'post_priority.picker.cancel',
                  defaultMessage: 'Cancel',
                  style: style.cancelButtonText,
                ),
              ),
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              onTap: onSubmit,
              child: Container(
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  color: theme.buttonBg,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: FormattedText(
                  id: 'post_priority.picker.apply',
                  defaultMessage: 'Apply',
                  style: style.applyButtonText,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  TextStyle get cancelButtonText => TextStyle(
        color: theme.buttonBg,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      );

  TextStyle get applyButtonText => TextStyle(
        color: theme.buttonColor,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      );

  getStyleSheet(Theme theme) {
    return {
      'cancelButton': cancelButtonText,
      'applyButton': applyButtonText,
    };
  }
}
