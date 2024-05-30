import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_reanimated/flutter_reanimated.dart';
import 'package:mattermost_flutter/actions/app/global.dart';
import 'package:mattermost_flutter/components/touchable_emoji.dart';
import 'package:mattermost_flutter/utils/emoji.dart';
import 'package:mattermost_flutter/screens/emoji_picker/picker/header/skintone_selector/close_button.dart';
import 'package:mattermost_flutter/screens/emoji_picker/picker/header/skintone_selector/skin_selector.dart';
import 'package:mattermost_flutter/screens/emoji_picker/picker/header/skintone_selector/tooltip.dart';

class SkinToneSelector extends StatefulWidget {
  final ValueNotifier<double> containerWidth;
  final ValueNotifier<bool> isSearching;
  final String skinTone;
  final bool tutorialWatched;

  SkinToneSelector({
    required this.containerWidth,
    required this.isSearching,
    this.skinTone = 'default',
    required this.tutorialWatched,
  });

  @override
  _SkinToneSelectorState createState() => _SkinToneSelectorState();
}

class _SkinToneSelectorState extends State<SkinToneSelector> {
  bool expanded = false;
  bool tooltipVisible = false;
  late bool isTablet;
  late Map<String, String> skins;

  @override
  void initState() {
    super.initState();
    isTablet = useIsTablet();

    skins = skinCodes.map((key, value) {
      return MapEntry(key, key == 'default' ? 'hand' : 'hand_$value');
    });

    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!widget.tutorialWatched) {
        setState(() {
          tooltipVisible = true;
        });
      }
    });
  }

  void collapse() {
    setState(() {
      expanded = false;
    });
  }

  void expand() {
    setState(() {
      expanded = true;
    });
  }

  void close() {
    setState(() {
      tooltipVisible = false;
    });
    storeSkinEmojiSelectorTutorial();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (!expanded)
          Tooltip(
            isVisible: tooltipVisible,
            useInteractionManager: true,
            contentStyle: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              maxWidth: isTablet ? 352 : double.infinity,
              padding: EdgeInsets.zero,
            ),
            content: SkinSelectorTooltip(onClose: close),
            placement: isTablet ? TooltipPlacement.left : TooltipPlacement.top,
            onClose: close,
            tooltipStyle: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black,
                  offset: Offset(0, 2),
                  blurRadius: 2,
                  spreadRadius: 0.16,
                ),
              ],
            ),
          ),
        AnimatedContainer(
          duration: Duration(milliseconds: 300),
          width: widget.isSearching.value ? 0 : 32,
          height: 34,
          margin: EdgeInsets.only(left: Platform.isAndroid ? 10 : 0),
          child: AnimatedOpacity(
            opacity: widget.isSearching.value ? 0 : 1,
            duration: Duration(milliseconds: 350),
            child: TouchableEmoji(
              name: skins[widget.skinTone]!,
              onEmojiPress: expand,
              size: 28,
            ),
          ),
        ),
        if (expanded)
          AnimatedContainer(
            duration: Duration(milliseconds: 250),
            width: widget.containerWidth.value,
            child: Row(
              children: [
                if (!isTablet) CloseButton(onPress: collapse),
                SkinSelector(
                  selected: widget.skinTone,
                  skins: skins.values.toList(),
                  onSelectSkin: collapse,
                ),
                if (isTablet) CloseButton(onPress: collapse),
              ],
            ),
          ),
      ],
    );
  }
}
