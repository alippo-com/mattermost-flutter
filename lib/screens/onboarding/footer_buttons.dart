import 'package:flutter/material.dart';
import 'package:mattermost_flutter/components/compass_icon.dart';
import 'package:mattermost_flutter/components/formatted_text.dart';
import 'package:mattermost_flutter/utils/theme.dart';

class FooterButtons extends StatelessWidget {
  final Theme theme;
  final int lastSlideIndex;
  final Function nextSlideHandler;
  final Function signInHandler;
  final ValueNotifier<double> scrollX; // Equivalent of Animated.SharedValue in Flutter

  FooterButtons({
    required this.theme,
    required this.lastSlideIndex,
    required this.nextSlideHandler,
    required this.signInHandler,
    required this.scrollX,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final buttonWidth = width * 0.8; // Assuming ONBOARDING_CONTENT_MAX_WIDTH is handled similarly
    final styles = getStyleSheet(theme);

    final penultimateSlide = lastSlideIndex - 1;

    final inputRange = [penultimateSlide.toDouble() * width, lastSlideIndex.toDouble() * width];

    return ValueListenableBuilder<double>(
      valueListenable: scrollX,
      builder: (context, value, child) {
        final interpolatedWidth = Tween(begin: 120.0, end: buttonWidth).animate(
          CurvedAnimation(
            parent: AlwaysStoppedAnimation(value / lastSlideIndex),
            curve: Curves.linear,
          ),
        ).value;

        final opacityNextText = Tween(begin: 1.0, end: 0.0).animate(
          CurvedAnimation(
            parent: AlwaysStoppedAnimation(value / lastSlideIndex),
            curve: Curves.linear,
          ),
        ).value;

        final opacitySignInText = Tween(begin: 1.0, end: 0.0).animate(
          CurvedAnimation(
            parent: AlwaysStoppedAnimation(value / lastSlideIndex),
            curve: Curves.linear,
          ),
        ).value;

        final opacitySignInButton = Tween(begin: 1.0, end: 0.0).animate(
          CurvedAnimation(
            parent: AlwaysStoppedAnimation(value / lastSlideIndex),
            curve: Curves.linear,
          ),
        ).value;

        return Column(
          children: [
            GestureDetector(
              onTap: nextSlideHandler,
              child: Container(
                width: interpolatedWidth,
                margin: EdgeInsets.only(top: 5),
                decoration: BoxDecoration(
                  color: buttonBackgroundStyle(theme, 'lg', 'primary', 'default'),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Opacity(
                      opacity: opacityNextText,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FormattedText(
                            id: 'mobile.onboarding.next',
                            defaultMessage: 'Next',
                            style: buttonTextStyle(theme, 'lg', 'primary', 'default'),
                          ),
                          CompassIcon(
                            name: 'arrow-forward-ios',
                            style: TextStyle(
                              color: theme.buttonColor,
                              fontSize: 12,
                              marginLeft: 5,
                              marginTop: 4.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Opacity(
                      opacity: opacitySignInText,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FormattedText(
                            id: 'mobile.onboarding.sign_in_to_get_started',
                            defaultMessage: 'Sign in to get started',
                            style: buttonTextStyle(theme, 'lg', 'primary', 'default'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: signInHandler,
              child: Opacity(
                opacity: opacitySignInButton,
                child: Container(
                  margin: EdgeInsets.only(top: 5),
                  decoration: BoxDecoration(
                    color: buttonBackgroundStyle(theme, 'lg', 'link', 'default'),
                  ),
                  child: FormattedText(
                    id: 'mobile.onboarding.sign_in',
                    defaultMessage: 'Sign in',
                    style: buttonTextStyle(theme, 'lg', 'primary', 'inverted'),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Map<String, dynamic> getStyleSheet(Theme theme) {
    return {
      'button': {
        'marginTop': 5.0,
        'justifyContent': MainAxisAlignment.center,
        'alignItems': Alignment.center,
      },
      'rowIcon': {
        'color': theme.buttonColor,
        'fontSize': 12.0,
        'marginLeft': 5.0,
        'marginTop': 4.5,
      },
      'nextButtonText': {
        'flexDirection': Axis.horizontal,
        'position': 'absolute',
        'justifyContent': MainAxisAlignment.center,
        'width': 120.0,
      },
      'signInButtonText': {
        'flexDirection': Axis.horizontal,
      },
      'footerButtonsContainer': {
        'flexDirection': Axis.vertical,
        'height': 120.0,
        'marginTop': 25.0,
        'marginBottom': 15.0,
        'width': double.infinity,
        'alignItems': Alignment.center,
      },
    };
  }
}
