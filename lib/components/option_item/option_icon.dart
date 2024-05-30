
import 'package:flutter/material.dart';
import 'package:mattermost_flutter/components/compass_icon.dart'; // Custom widget
// Custom utility
import 'package:mattermost_flutter/utils/theme.dart'; // Custom utility

class OptionIcon extends StatefulWidget {
  final String icon;
  final String? iconColor;
  final bool destructive;

  OptionIcon({required this.icon, this.iconColor, this.destructive = false});

  @override
  _OptionIconState createState() => _OptionIconState();
}

class _OptionIconState extends State<OptionIcon> {
  bool failedToLoadImage = false;

  void onErrorLoadingIcon() {
    setState(() {
      failedToLoadImage = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconAsSource = widget.icon;

    if (isValidUrl(iconAsSource) && !failedToLoadImage) {
      return Image.network(
        iconAsSource,
        width: 24,
        height: 24,
        errorBuilder: (context, error, stackTrace) => onErrorLoadingIcon(),
      );
    }

    final iconName = failedToLoadImage ? 'power-plugin-outline' : widget.icon;
    return CompassIcon(
      name: iconName,
      size: 24,
      color: widget.iconColor ?? 
              (widget.destructive ? theme.colorScheme.error : theme.iconTheme.color?.withOpacity(0.64)),
    );
  }
}
