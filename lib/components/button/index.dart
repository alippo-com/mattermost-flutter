// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:mattermost_flutter/components/compass_icon.dart';

class ConditionalProps {
  final String? iconName;
  final double? iconSize;

  ConditionalProps({this.iconName, this.iconSize});
}

class ButtonProps extends ConditionalProps {
  final ThemeData theme;
  final TextStyle? textStyle;
  final BoxDecoration? backgroundStyle;
  final ButtonSize? size;
  final ButtonEmphasis? emphasis;
  final ButtonType? buttonType;
  final ButtonState? buttonState;
  final String? testID;
  final VoidCallback onPress;
  final String text;
  final Widget? iconComponent;

  ButtonProps({
    required this.theme,
    this.textStyle,
    this.backgroundStyle,
    this.size,
    this.emphasis,
    this.buttonType,
    this.buttonState,
    required this.onPress,
    required this.text,
    this.testID,
    String? iconName,
    double? iconSize,
    this.iconComponent,
  }) : super(iconName: iconName, iconSize: iconSize);
}

class Button extends StatelessWidget {
  final ButtonProps props;
  
  Button(this.props);

  @override
  Widget build(BuildContext context) {
    final bgStyle = [
      buttonBackgroundStyle(props.theme, props.size, props.emphasis, props.buttonType, props.buttonState),
      props.backgroundStyle,
    ];

    final txtStyle = [
      buttonTextStyle(props.theme, props.size, props.emphasis, props.buttonType),
      props.textStyle,
    ];

    final containerStyle = props.iconSize != null
      ? [
          Row(
            children: [
              Container(minHeight: props.iconSize!),
            ],
          )
        ]
      : [];

    Widget? icon;

    if (props.iconComponent != null) {
      icon = props.iconComponent;
    } else if (props.iconName != null) {
      icon = CompassIcon(
        name: props.iconName!,
        size: props.iconSize!,
        color: txtStyle.first.color,
        style: const Padding(padding: EdgeInsets.only(right: 7)),
      );
    }

    return GestureDetector(
      onTap: props.onPress,
      child: Container(
        decoration: BoxDecoration(
          color: bgStyle.first.color,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Row(
          children: [
            if (icon != null) icon,
            Text(
              props.text,
              style: txtStyle.first,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
