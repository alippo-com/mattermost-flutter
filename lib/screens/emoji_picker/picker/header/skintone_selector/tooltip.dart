import 'package:flutter/material.dart';
import 'package:mattermost_flutter/components/compass_icon.dart';
import 'package:mattermost_flutter/components/formatted_text.dart';
import 'package:mattermost_flutter/constants/preferences.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/typography.dart';

class SkinSelectorTooltip extends StatelessWidget {
  final VoidCallback onClose;

  SkinSelectorTooltip({required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(top: 22.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FormattedText(
                  id: 'skintone_selector.tooltip.title',
                  defaultMessage: 'Choose your default skin tone',
                  style: TextStyle(
                    color: Preferences.THEMES.denim.centerChannelColor,
                    fontSize: getTypographySize('Body', 200),
                    fontWeight: FontWeight.w600, // SemiBold
                  ),
                  testID: 'skin_selector.tooltip.title',
                ),
                Spacer(),
                IconButton(
                  icon: CompassIcon(
                    color: changeOpacity(Preferences.THEMES.denim.centerChannelColor, 0.56),
                    name: 'close',
                    size: 18.0,
                  ),
                  onPressed: onClose,
                  padding: EdgeInsets.all(0),
                  constraints: BoxConstraints(),
                  testID: 'skin_selector.tooltip.close.button',
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 12.0, bottom: 24.0),
            child: FormattedText(
              id: 'skintone_selector.tooltip.description',
              defaultMessage: 'You can now choose the skin tone you prefer to use for your emojis.',
              style: TextStyle(
                color: Preferences.THEMES.denim.centerChannelColor,
                fontSize: getTypographySize('Body', 200),
                fontWeight: FontWeight.w400, // Regular
              ),
              testID: 'skin_selector.tooltip.description',
            ),
          ),
        ],
      ),
    );
  }
}
