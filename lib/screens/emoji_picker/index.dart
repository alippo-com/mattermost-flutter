
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mattermost_flutter/constants/events.dart';
import 'package:mattermost_flutter/screens/bottom_sheet.dart';
import 'package:mattermost_flutter/screens/emoji_picker/picker.dart';
import 'package:mattermost_flutter/screens/emoji_picker/picker_footer.dart';
import 'package:mattermost_flutter/types/screens/navigation.dart';

class EmojiPickerScreen extends StatefulWidget {
  final AvailableScreens componentId;
  final void Function(String) onEmojiPress;
  final String closeButtonId;

  EmojiPickerScreen({
    required this.componentId,
    required this.onEmojiPress,
    required this.closeButtonId,
  });

  @override
  _EmojiPickerScreenState createState() => _EmojiPickerScreenState();
}

class _EmojiPickerScreenState extends State<EmojiPickerScreen> {
  void _handleEmojiPress(String emoji) {
    widget.onEmojiPress(emoji);
    DeviceEventEmitter.emit(Events.CLOSE_BOTTOM_SHEET);
  }

  Widget _renderContent() {
    return Picker(
      onEmojiPress: _handleEmojiPress,
      testID: 'emoji_picker',
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomSheet(
      renderContent: _renderContent,
      closeButtonId: widget.closeButtonId,
      componentId: widget.componentId,
      contentStyle: const ContentStyle(paddingTop: 14),
      initialSnapIndex: 1,
      footerComponent: PickerFooter(),
      testID: 'post_options',
    );
  }
}

class ContentStyle {
  final double paddingTop;

  const ContentStyle({required this.paddingTop});
}
