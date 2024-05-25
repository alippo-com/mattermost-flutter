// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:mattermost_flutter/utils/message_attachment_colors.dart';
import 'package:mattermost_flutter/utils/tap.dart';
import 'package:mattermost_flutter/utils/theme.dart';

import 'action_button_text.dart';

class ActionButton extends StatefulWidget {
  final String? buttonColor;
  final String? cookie;
  final bool? disabled;
  final String id;
  final String name;
  final String postId;
  final Theme theme;

  const ActionButton({
    Key? key,
    this.buttonColor,
    this.cookie,
    this.disabled,
    required this.id,
    required this.name,
    required this.postId,
    required this.theme,
  }) : super(key: key);

  @override
  _ActionButtonState createState() => _ActionButtonState();
}

class _ActionButtonState extends State<ActionButton> {
  bool pressed = false;
  late String serverUrl;
  late Map<String, dynamic> style;

  @override
  void initState() {
    super.initState();
    serverUrl = useServerUrl();
    style = getStyleSheet(widget.theme);
  }

  Map<String, dynamic> getStyleSheet(Theme theme) {
    final statusColors = getStatusColors(theme);
    return {
      'button': {
        'borderRadius': 4.0,
        'borderColor': changeOpacity(statusColors['default'], 0.25),
        'borderWidth': 2.0,
        'opacity': 1.0,
        'alignItems': Alignment.center,
        'marginTop': 12.0,
        'justifyContent': MainAxisAlignment.center,
        'height': 36.0,
      },
      'buttonDisabled': {
        'backgroundColor': changeOpacity(theme.buttonBg, 0.3),
      },
      'text': {
        'color': statusColors['default'],
        'fontSize': 15.0,
        'fontFamily': 'OpenSans-SemiBold',
        'lineHeight': 17.0,
      },
    };
  }

  @override
  Widget build(BuildContext context) {
    var customButtonStyle;
    var customButtonTextStyle;

    if (widget.buttonColor != null) {
      final statusColors = getStatusColors(widget.theme);
      final hexColor = statusColors[widget.buttonColor] ?? widget.theme[widget.buttonColor] ?? widget.buttonColor;
      customButtonStyle = {'borderColor': changeOpacity(hexColor, 0.25), 'backgroundColor': Colors.white};
      customButtonTextStyle = {'color': hexColor};
    }

    return GestureDetector(
      onTap: widget.disabled == true ? null : () async {
        if (!pressed) {
          setState(() => pressed = true);
          await postActionWithCookie(serverUrl, widget.postId, widget.id, widget.cookie ?? '');
          setState(() => pressed = false);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(style['button']['borderRadius']),
          border: Border.all(color: style['button']['borderColor'], width: style['button']['borderWidth']),
          color: customButtonStyle != null ? customButtonStyle['backgroundColor'] : null,
        ),
        alignment: style['button']['alignItems'],
        margin: EdgeInsets.only(top: style['button']['marginTop']),
        height: style['button']['height'],
        child: ActionButtonText(
          message: widget.name,
          style: TextStyle(
            color: customButtonTextStyle != null ? customButtonTextStyle['color'] : style['text']['color'],
            fontSize: style['text']['fontSize'],
            fontFamily: style['text']['fontFamily'],
            height: style['text']['lineHeight'],
          ),
        ),
      ),
    );
  }
}
