import 'package:flutter/material.dart';
import 'package:mattermost_flutter/types/theme_model.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/components/option_item.dart';
import 'package:mattermost_flutter/components/typography.dart';

class SettingOption extends StatelessWidget {
  final OptionItemProps props;

  SettingOption({required this.props});

  @override
  Widget build(BuildContext context) {
    final ThemeModel theme = useTheme(context);
    final styles = _getStyleSheet(theme);

    final bool useRadioButton = props.type == 'select' && Theme.of(context).platform == TargetPlatform.android;

    return OptionItem(
      optionDescriptionTextStyle: styles['optionDescriptionTextStyle'],
      optionLabelTextStyle: styles['optionLabelTextStyle'],
      containerStyle: [
        styles['container'],
        if (props.description != null) {'marginVertical': 12},
      ],
      props: props,
      type: useRadioButton ? 'radio' : props.type,
    );
  }

  Map<String, dynamic> _getStyleSheet(ThemeModel theme) {
    return {
      'container': {
        'paddingHorizontal': 20,
      },
      'optionLabelTextStyle': TextStyle(
        color: theme.centerChannelColor,
        ...typography('Body', 200, 'Regular'),
        marginBottom: 4,
      ),
      'optionDescriptionTextStyle': TextStyle(
        color: changeOpacity(theme.centerChannelColor, 0.64),
        ...typography('Body', 75, 'Regular'),
      ),
    };
  }
}
