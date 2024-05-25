
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mattermost_flutter/actions/remote/custom_emoji.dart';
import 'package:mattermost_flutter/context/server.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/helpers/api/general.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'filtered.dart';
import 'header.dart';
import 'sections.dart';

class Picker extends StatefulWidget {
  final List<dynamic> customEmojis; // Update the type as per your model
  final bool customEmojisEnabled;
  final Function(String) onEmojiPress;
  final List<String> recentEmojis;
  final String testID;

  Picker({
    required this.customEmojis,
    required this.customEmojisEnabled,
    required this.onEmojiPress,
    required this.recentEmojis,
    this.testID = '',
  });

  @override
  _PickerState createState() => _PickerState();
}

class _PickerState extends State<Picker> {
  String? searchTerm;

  void onCancelSearch() {
    setState(() {
      searchTerm = null;
    });
  }

  void onChangeSearchTerm(String text) {
    setState(() {
      searchTerm = text;
      searchCustom(text.replaceAll(RegExp(r'^:|:$'), '').trim());
    });
  }

  void searchCustom(String text) {
    if (text.isNotEmpty && text.length > 1) {
      debounce(() => searchCustomEmojis(context.read<ServerUrl>(), text), Duration(milliseconds: 500));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<Theme>();

    Widget emojiList;
    final term = searchTerm?.replaceAll(RegExp(r'^:|:$'), '').trim();
    if (term != null && term.isNotEmpty) {
      emojiList = EmojiFiltered(
        customEmojis: widget.customEmojis,
        searchTerm: term,
        onEmojiPress: widget.onEmojiPress,
      );
    } else {
      emojiList = EmojiSections(
        customEmojis: widget.customEmojis,
        customEmojisEnabled: widget.customEmojisEnabled,
        onEmojiPress: widget.onEmojiPress,
        recentEmojis: widget.recentEmojis,
      );
    }

    return Container(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.only(bottom: 5),
            child: PickerHeader(
              autoCapitalize: TextCapitalization.none,
              keyboardAppearance: getKeyboardAppearanceFromTheme(theme),
              onCancel: onCancelSearch,
              onChangeText: onChangeSearchTerm,
              testID: '${widget.testID}.search_bar',
              value: searchTerm,
            ),
          ),
          Expanded(
            child: emojiList,
          ),
        ],
      ),
    );
  }
}
