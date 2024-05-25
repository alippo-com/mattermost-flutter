
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/hooks/device.dart';
import 'package:mattermost_flutter/hooks/emoji_category_bar.dart';
import 'package:mattermost_flutter/components/emoji_category_bar.dart';

class PickerFooter extends StatelessWidget {
  final BottomSheetFooterProps props;

  PickerFooter({required this.props});

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<Theme>(context);
    final keyboardHeight = useKeyboardHeight();
    final animatedSheetState = useBottomSheetInternal().animatedSheetState;
    final expand = useBottomSheet().expand;

    void scrollToIndex(int index) {
      if (animatedSheetState.value == SHEET_STATE.EXTENDED) {
        selectEmojiCategoryBarSection(index);
        return;
      }
      expand();

      // Wait until the bottom sheet is expanded
      while (animatedSheetState.value != SHEET_STATE.EXTENDED) {
        // Do nothing
      }

      selectEmojiCategoryBarSection(index);
    }

    final animatedStyle = useAnimatedStyle(() {
      final paddingBottom = withTiming(
        Platform.isIOS ? 20 : 0,
        duration: Duration(milliseconds: 250),
      );
      return {
        'backgroundColor': theme.centerChannelBg,
        'paddingBottom': paddingBottom,
      };
    }, [theme]);

    final heightAnimatedStyle = useAnimatedStyle(() {
      int height = 55;
      if (keyboardHeight == 0 && Platform.isIOS) {
        height += 20;
      } else if (keyboardHeight != 0) {
        height = 0;
      }

      return {
        'height': height,
      };
    }, [keyboardHeight]);

    return BottomSheetFooter(
      style: heightAnimatedStyle,
      props: props,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 250),
        style: animatedStyle,
        child: EmojiCategoryBar(onSelect: scrollToIndex),
      ),
    );
  }
}
