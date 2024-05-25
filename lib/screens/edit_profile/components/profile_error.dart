import 'package:flutter/material.dart';
import 'package:mattermost_flutter/components/compass_icon.dart';
import 'package:mattermost_flutter/components/error_text.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/typography.dart';

class ProfileError extends StatelessWidget {
  final dynamic error;

  ProfileError({Key? key, required this.error}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = useTheme(context);
    final style = getStyleSheet(theme);

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(maxHeight: 48),
      decoration: BoxDecoration(
        color: changeOpacity(theme.errorTextColor, 0.08),
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CompassIcon(
            style: style['icon'],
            size: 18,
            name: 'alert-outline',
          ),
          ErrorTextComponent(
            testID: 'edit_profile.error.text',
            error: error,
            textStyle: style['text'],
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> getStyleSheet(ThemeData theme) {
    return {
      'errorContainer': BoxDecoration(
        color: changeOpacity(theme.errorTextColor, 0.08),
        borderRadius: BorderRadius.circular(4.0),
      ),
      'text': typography('Heading', 100).copyWith(color: theme.centerChannelColor),
      'icon': typography('Heading', 300).copyWith(
        color: changeOpacity(theme.dndIndicator, 0.64),
        marginRight: 9.0,
      ),
    };
  }
}
