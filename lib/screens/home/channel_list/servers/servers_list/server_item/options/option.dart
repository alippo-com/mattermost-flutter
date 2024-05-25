
import 'package:flutter/material.dart';
import 'package:flutter/animation.dart';
import 'package:mattermost_flutter/components/compass_icon.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/types/typography.dart';
import 'package:flutter/widgets.dart';

class ServerOption extends StatelessWidget {
  final Color color;
  final String icon;
  final VoidCallback onPress;
  final double positionX;
  final Animation<double> progress;
  final BoxDecoration style;
  final String testID;
  final String text;
  
  ServerOption({
    required this.color,
    required this.icon,
    required this.onPress,
    required this.positionX,
    required this.progress,
    required this.style,
    required this.testID,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final styles = _getStyleSheet(theme);

    final containerStyle = BoxDecoration(
      color: color,
      ...style,
    );

    final centeredStyle = styles["centered"];

    final trans = Tween<double>(begin: positionX, end: 0).animate(progress);

    return AnimatedBuilder(
      animation: trans,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(trans.value, 0),
          child: Container(
            decoration: containerStyle,
            child: InkWell(
              onTap: onPress,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CompassIcon(
                    color: theme.buttonColor,
                    name: icon,
                    size: 24,
                  ),
                  Text(
                    text,
                    style: styles["text"],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Map<String, dynamic> _getStyleSheet(ThemeData theme) {
    return {
      "centered": BoxDecoration(
        alignItems: Alignment.center,
        justifyContent: MainAxisAlignment.center,
      ),
      "container": BoxDecoration(
        height: 72,
        width: 72,
      ),
      "text": TextStyle(
        color: theme.sidebarText,
        ...typography("Body", 75, "SemiBold"),
      ),
    };
  }
}
