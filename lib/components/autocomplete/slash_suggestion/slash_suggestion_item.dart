
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:fast_image/fast_image.dart';
import 'package:mattermost_flutter/constants/apps.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/components/compass_icon.dart';
import 'package:mattermost_flutter/components/touchable_with_feedback.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/types/theme.dart';

const slashIcon = 'assets/images/autocomplete/slash_command.png';

class SlashSuggestionItem extends StatelessWidget {
  final String complete;
  final String description;
  final String hint;
  final void Function(String) onPress;
  final String suggestion;
  final String icon;

  const SlashSuggestionItem({
    Key? key,
    this.complete = '',
    required this.description,
    required this.hint,
    required this.onPress,
    required this.suggestion,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeNotifier>(context).theme;
    final style = getStyleFromTheme(theme);

    final iconAsSource = useMemo(() {
      return NetworkImage(icon);
    }, [icon]);

    final touchableStyle = useMemo(() {
      final insets = MediaQuery.of(context).padding;
      return EdgeInsets.only(left: insets.left, right: insets.right);
    }, [context]);

    final completeSuggestion = useCallback(() {
      onPress(complete);
    }, [onPress, complete]);

    String suggestionText = suggestion;
    if (suggestionText.isNotEmpty && suggestionText[0] == '/' && complete.split(' ').length == 1) {
      suggestionText = suggestionText.substring(1);
    }

    if (hint.isNotEmpty) {
      if (suggestionText.isNotEmpty) {
        suggestionText += ' $hint';
      } else {
        suggestionText = hint;
      }
    }

    Widget image = Image.asset(
      slashIcon,
      style: style.slashIcon,
    );

    if (icon == COMMAND_SUGGESTION_ERROR) {
      image = CompassIcon(
        name: 'alert-circle-outline',
        size: 24,
      );
    } else if (icon.startsWith('http')) {
      image = FastImage(
        imageUrl: icon,
        style: style.uriIcon,
      );
    } else if (icon.startsWith('data:')) {
      if (icon.startsWith('data:image/svg+xml')) {
        String xml = '';
        try {
          xml = base64.decode(icon.substring('data:image/svg+xml;base64,'.length));
          image = SvgPicture.string(
            xml,
            width: 32,
            height: 32,
          );
        } catch (error) {
          // Do nothing
        }
      } else {
        image = FastImage(
          imageUrl: icon,
          style: style.uriIcon,
        );
      }
    }

    final slashSuggestionItemTestId = 'autocomplete.slash_suggestion_item.$suggestion';

    return TouchableWithFeedback(
      onPress: completeSuggestion,
      style: touchableStyle,
      underlayColor: changeOpacity(theme.buttonBg!, 0.08),
      testID: slashSuggestionItemTestId,
      type: TouchableType.native,
      child: Row(
        children: [
          Container(
            style: style.icon,
            child: image,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  suggestionText,
                  style: style.suggestionName,
                  testID: '$slashSuggestionItemTestId.name',
                ),
                if (description.isNotEmpty)
                  Text(
                    description,
                    overflow: TextOverflow.ellipsis,
                    style: style.suggestionDescription,
                    testID: '$slashSuggestionItemTestId.description',
                    maxLines: 1,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Map<String, dynamic> getStyleFromTheme(Theme theme) {
  return {
    'icon': {
      'fontSize': 24,
      'backgroundColor': changeOpacity(theme.centerChannelColor, 0.08),
      'width': 35,
      'height': 35,
      'marginRight': 12,
      'borderRadius': 4,
      'justifyContent': 'center',
      'alignItems': 'center',
      'marginTop': 8,
    },
    'uriIcon': {
      'width': 16,
      'height': 16,
    },
    'container': {
      'flexDirection': 'row',
      'alignItems': 'center',
      'paddingBottom': 8,
      'overflow': 'hidden',
    },
    'slashIcon': {
      'height': 16,
      'width': 10,
      'tintColor': theme.centerChannelColor,
    },
    'suggestionContainer': {
      'flex': 1,
    },
    'suggestionDescription': {
      'fontSize': 12,
      'color': changeOpacity(theme.centerChannelColor, 0.56),
    },
    'suggestionName': {
      'fontSize': 15,
      'color': theme.centerChannelColor,
      'marginBottom': 4,
    },
  };
}
