
import 'package:flutter/material.dart';
import 'package:mattermost_flutter/components/emoji/emoji.dart'; // Adjust the import path as necessary

class EmojiWrapper extends StatefulWidget {
  final Map<String, dynamic> props;

  EmojiWrapper({required this.props, Key? key}) : super(key: key);

  @override
  State<EmojiWrapper> createState() => _EmojiWrapperState();
}

class _EmojiWrapperState extends State<EmojiWrapper> {
  late Widget emojiComponent;

  @override
  void initState() {
    super.initState();
    emojiComponent = _loadEmojiComponent();
  }

  Widget _loadEmojiComponent() {
    // Logic to load the emoji component, analogous to useMemo in React
    // Assuming Emoji is a Flutter widget imported from emoji.dart
    return Emoji(); // Adjust as necessary
  }

  @override
  Widget build(BuildContext context) {
    return emojiComponent; // Adjust to pass props if necessary
  }
}
