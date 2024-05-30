
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:mattermost_flutter/components/compass_icon.dart';
import 'package:mattermost_flutter/components/formatted_text.dart';
import 'package:mattermost_flutter/hooks/header.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/typography.dart';
import 'package:mattermost_flutter/utils/change_opacity.dart';
import 'package:reactive_forms/reactive_forms.dart';

class Header extends HookWidget {
  final int index;
  final VoidCallback onClose;
  final double total;
  final AnimationController style;

  Header({
    required this.index,
    required this.onClose,
    required this.style,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final insets = MediaQuery.of(context).padding;
    final width = MediaQuery.of(context).size.width;
    final height = useDefaultHeaderHeight() - insets.top;
    final top = insets.top;

    final topContainerStyle = useMemo(() => [
      Container(
        height: top,
        color: Colors.black,
      )
    ], [top]);

    final containerStyle = useMemo(() => [
      Container(
        alignment: Alignment.center,
        backgroundColor: Colors.black,
        border: Border(
          bottom: BorderSide(
            color: changeOpacity(Colors.white, 0.4),
            width: 1,
          ),
        ),
        flexDirection: Axis.horizontal,
      )
    ], [height]);

    final iconStyle = useMemo(() => [
      Container(
        alignment: Alignment.center,
        justifyContent: Alignment.center,
        height: double.infinity,
        width: height,
      )
    ], [height]);

    final titleStyle = useMemo(() => [
      Container(
        width: width - (height * 2),
      )
    ], [height, width]);

    final titleValue = useMemo(() => {
        return {
        'index': index + 1,
        'total': total,
        };
    }, [index, total]);

    return AnimatedBuilder(
      animation: style,
      builder: (context, child) {
        return SafeArea(
          child: Column(
            children: [
            ...topContainerStyle,
            Row(
              children: [
              GestureDetector(
              onTap: onClose,
              child: ...iconStyle,
              child: CompassIcon(
                color: Colors.white,
                iconName: 'close',
                size: 24,
              ),
            ),
            Container(
            ...titleStyle,
            child: FormattedText(
            id: 'mobile.gallery.title',
            defaultMessage: '{index} of {total}',
            style: typography('Heading', 300).copyWith(
              color: Colors.white,
            ),
            values: titleValue,
          ),
        ),
        ],
        ),
        ],
        ),
        );
      },
    );
  }
}
