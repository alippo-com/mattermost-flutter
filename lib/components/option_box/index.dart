import 'package:flutter/material.dart';
import 'package:mattermost_flutter/components/compass_icon.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/typography.dart';

const double OPTIONS_HEIGHT = 62;

class OptionBox extends StatefulWidget {
  final String? activeIconName;
  final String? activeText;
  final BoxDecoration? containerStyle;
  final String iconName;
  final bool? isActive;
  final VoidCallback onPress;
  final String? testID;
  final String text;
  final String? destructiveIconName;
  final String? destructiveText;
  final bool? isDestructive;

  OptionBox({
    this.activeIconName,
    this.activeText,
    this.containerStyle,
    required this.iconName,
    this.isActive,
    required this.onPress,
    this.testID,
    required this.text,
    this.destructiveIconName,
    this.destructiveText,
    this.isDestructive,
  });

  @override
  _OptionBoxState createState() => _OptionBoxState();
}

class _OptionBoxState extends State<OptionBox> {
  late bool activated;
  late BoxDecoration styles;
  late Theme theme;

  @override
  void initState() {
    super.initState();
    activated = widget.isActive ?? false;
    theme = useTheme();
    styles = getStyleSheet(theme);
  }

  BoxDecoration getStyleSheet(Theme theme) {
    return BoxDecoration(
      backgroundColor: changeOpacity(theme.centerChannelColor, 0.04),
      borderRadius: BorderRadius.circular(4),
      boxShadow: [
        BoxShadow(
          color: changeOpacity(theme.centerChannelColor, 0.04),
          blurRadius: 4,
        ),
      ],
    );
  }

  @override
  void didUpdateWidget(OptionBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isActive != widget.isActive) {
      setState(() {
        activated = widget.isActive ?? false;
      });
    }
  }

  void handleOnPress() {
    if (widget.activeIconName != null || widget.activeText != null) {
      setState(() {
        activated = !activated;
      });
    }
    widget.onPress();
  }

  @override
  Widget build(BuildContext context) {
    final BoxDecoration pressedStyle = BoxDecoration(
      color: activated ? changeOpacity(theme.buttonBg, 0.08) : null,
    );

    return GestureDetector(
        onTap: handleOnPress,
        child: Container(
            decoration: pressedStyle,
            child: Column(
                children: [
            CompassIcon(
            color: (widget.isDestructive ==
                true ? theme.dndIndicator : (activated ? theme.buttonBg :
                changeOpacity(theme.centerChannelColor, 0.56))),
    name: widget.destructiveIconName ?? (activated && widget.activeIconName != null ? widget.activeIconName! : widget.iconName),
    size: 24,
    ),
    Text(
    widget.destructiveText ?? (activated && widget.activeText != null ? widget.activeText! : widget.text),
    style: TextStyle(
    color: widget.isDestructive == true ? theme.dndIndicator : (activated ? theme.buttonBg : changeOpacity(theme.centerChannelColor, 0.56)),
    ...typography('Body', 50, 'SemiBold'),
    ),
    textAlign: TextAlign.center,
    ),
    ],
    ),
    ),
    );
  }
}