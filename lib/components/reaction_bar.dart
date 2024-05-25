// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:mattermost_flutter/actions/calls.dart';
import 'package:mattermost_flutter/components/emoji_button.dart';
import 'package:mattermost_flutter/utils/calls_theme.dart';
import 'package:mattermost_flutter/components/compass_icon.dart';
import 'package:mattermost_flutter/components/formatted_text.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/types/calls.dart';
import 'package:mattermost_flutter/types/typography.dart';

class ReactionBar extends HookWidget {
  final int raisedHand;

  ReactionBar({required this.raisedHand});

  @override
  Widget build(BuildContext context) {
    final theme = useTheme();
    final callsTheme = useMemo(() => makeCallsTheme(theme), [theme]);
    final style = getStyleSheet(callsTheme);
    final mediaQuery = MediaQuery.of(context);
    final width = mediaQuery.size.width;
    final height = mediaQuery.size.height;
    final isLandscape = width > height;

    final lowerHandText = FormattedText(
      id: 'mobile.calls_lower_hand',
      defaultMessage: 'Lower hand',
      style: raisedHand > 0 ? style.pressed : style.unPressed,
    );

    final raiseHandText = FormattedText(
      id: 'mobile.calls_raise_hand',
      defaultMessage: 'Raise hand',
      style: raisedHand > 0 ? style.pressed : style.unPressed,
    );

    final toggleRaiseHand = useCallback(() {
      if (raisedHand > 0) {
        unraiseHand();
      } else {
        raiseHand();
      }
    }, [raisedHand]);

    return Row(
      children: [
        Container(
          height: isLandscape ? 60 : 64,
          padding: EdgeInsets.symmetric(horizontal: 16),
          alignment: isLandscape ? Alignment.center : Alignment.bottomLeft,
          child: Pressable(
            style: [
              style.button,
              if (isLandscape) style.buttonLandscape,
              if (raisedHand > 0) style.buttonPressed,
            ],
            onPressed: toggleRaiseHand,
            child: Row(
              children: [
                CompassIcon(
                  name: raisedHand > 0 ? 'hand-right-outline-off' : 'hand-right',
                  size: 24,
                  style: raisedHand > 0 ? style.pressed : style.unPressed,
                ),
                raisedHand > 0 ? lowerHandText : raiseHandText,
              ],
            ),
          ),
        ),
        ...predefinedReactions.map((reaction) {
          return EmojiButton(
            key: reaction[0],
            emojiName: reaction[0],
            style: [style.button, if (isLandscape) style.buttonLandscape],
            onPressed: () => sendReaction(reaction),
          );
        }).toList(),
      ],
    );
  }

  List<List<String>> get predefinedReactions => [
        ['+1', '1F44D'],
        ['clap', '1F44F'],
        ['joy', '1F602'],
        ['heart', '2764-FE0F'],
      ];

  Map<String, dynamic> getStyleSheet(CallsTheme theme) => {
        'outerContainer': {
          'flexDirection': Axis.horizontal,
        },
        'container': {
          'flex': 1,
          'flexDirection': Axis.horizontal,
          'alignItems': CrossAxisAlignment.end,
          'justifyContent': MainAxisAlignment.spaceBetween,
          'height': 64.0,
          'paddingLeft': 16.0,
          'paddingRight': 16.0,
        },
        'containerLandscape': {
          'height': 60.0,
          'paddingBottom': 12.0,
          'justifyContent': MainAxisAlignment.center,
        },
        'button': {
          'display': FlexDisplay.flex,
          'flexDirection': Axis.horizontal,
          'alignItems': CrossAxisAlignment.center,
          'backgroundColor': changeOpacity(theme.buttonColor, 0.08),
          'borderRadius': 30.0,
          'height': 48.0,
          'maxWidth': 160.0,
          'paddingLeft': 10.0,
          'paddingRight': 10.0,
        },
        'buttonLandscape': {
          'marginRight': 12.0,
          'marginLeft': 12.0,
        },
        'buttonPressed': {
          'backgroundColor': theme.buttonColor,
        },
        'unPressed': {
          'color': changeOpacity(theme.buttonColor, 0.56),
        },
        'pressed': {
          'color': theme.callsBg,
        },
        'buttonText': {
          'marginLeft': 8.0,
          ...typography('Body', 200, 'SemiBold'),
        },
      };
}

class Pressable extends StatelessWidget {
  final List<dynamic> style;
  final VoidCallback onPressed;
  final Widget child;

  Pressable({required this.style, required this.onPressed, required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: style.contains('buttonPressed') ? Colors.blue : Colors.grey,
        ),
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: child,
      ),
    );
  }
}
