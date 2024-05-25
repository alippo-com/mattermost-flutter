import 'package:flutter/material.dart';
import 'package:mattermost_flutter/types/tutorial_item_bounds.dart';
import 'package:mattermost_flutter/components/tutorial_highlight/item.dart';

class TutorialHighlight extends StatefulWidget {
  final Widget? children;
  final TutorialItemBounds itemBounds;
  final double? itemBorderRadius;
  final VoidCallback onDismiss;
  final VoidCallback? onShow;

  const TutorialHighlight({
    Key? key,
    this.children,
    required this.itemBounds,
    this.itemBorderRadius,
    required this.onDismiss,
    this.onShow,
  }) : super(key: key);

  @override
  _TutorialHighlightState createState() => _TutorialHighlightState();
}

class _TutorialHighlightState extends State<TutorialHighlight> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.onShow != null) {
        Future.delayed(Duration(seconds: 1), widget.onShow);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Visibility(
      visible: widget.itemBounds.endX > 0,
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: GestureDetector(
          onTap: widget.onDismiss,
          child: Stack(
            children: [
              HighlightItem(
                borderRadius: widget.itemBorderRadius,
                itemBounds: widget.itemBounds,
                height: size.height,
                width: size.width,
                onDismiss: widget.onDismiss,
              ),
              if (widget.children != null) widget.children!,
            ],
          ),
        ),
      ),
    );
  }
}
