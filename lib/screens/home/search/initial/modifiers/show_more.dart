import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; 
import 'package:mattermost_flutter/components/option_item.dart'; 
import 'package:mattermost_flutter/context/theme.dart'; 
import 'package:mattermost_flutter/utils/i18n.dart'; 
import 'package:mattermost_flutter/utils/theme.dart'; 
import 'package:mattermost_flutter/utils/typography.dart'; 

class ShowMoreButton extends StatelessWidget {
  final VoidCallback onPress;
  final bool showMore;

  const ShowMoreButton({
    required this.onPress,
    required this.showMore,
    Key? key,
  }) : super(key: key);

  TextStyle getShowMoreStyle(ThemeData theme) {
    return TextStyle(
      color: theme.buttonColor,
      padding: EdgeInsets.only(left: 20),
      ...typography('Body', 200, 'SemiBold'), 
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); 
    final styles = getShowMoreStyle(theme);

    String id = 'mobile.search.show_more';
    String defaultMessage = AppLocalizations.of(context)!.showMore; 
    if (showMore) {
      id = 'mobile.search.show_less';
      defaultMessage = AppLocalizations.of(context)!.showLess; 
    }

    return OptionItem(
      action: onPress,
      testID: 'mobile.search.show_more',
      type: 'default',
      label: AppLocalizations.of(context)!.translate(id, defaultMessage),
      optionLabelTextStyle: styles,
    );
  }
}
