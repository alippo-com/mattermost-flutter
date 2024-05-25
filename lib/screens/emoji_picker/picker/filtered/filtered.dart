
import 'package:flutter/material.dart';
import 'package:mattermost_flutter/components/no_results_with_term.dart';
import 'package:mattermost_flutter/utils/emoji_helpers.dart';
import 'package:mattermost_flutter/utils/device.dart';
import 'package:mattermost_flutter/components/emoji_item.dart';
import 'package:provider/provider.dart';
import 'package:fuse/fuse.dart'; // Assuming similar functionality exists in Dart

class EmojiFiltered extends StatefulWidget {
  final List<CustomEmojiModel> customEmojis;
  final String skinTone;
  final String searchTerm;
  final Function(String) onEmojiPress;

  EmojiFiltered({
    required this.customEmojis,
    required this.skinTone,
    required this.searchTerm,
    required this.onEmojiPress,
  });

  @override
  _EmojiFilteredState createState() => _EmojiFilteredState();
}

class _EmojiFilteredState extends State<EmojiFiltered> {
  late List<String> emojis;
  late Fuse fuse;
  late List<String> data;

  @override
  void initState() {
    super.initState();
    emojis = getEmojis(widget.skinTone, widget.customEmojis);
    final options = {
      'findAllMatches': true,
      'ignoreLocation': true,
      'includeMatches': true,
      'shouldSort': false,
      'includeScore': true,
    };
    fuse = Fuse(emojis, options);
    data = widget.searchTerm.isEmpty ? [] : searchEmojis(fuse, widget.searchTerm);
  }

  @override
  void didUpdateWidget(covariant EmojiFiltered oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.searchTerm != oldWidget.searchTerm) {
      setState(() {
        data = widget.searchTerm.isEmpty ? [] : searchEmojis(fuse, widget.searchTerm);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = useIsTablet(context);

    return Scaffold(
      body: data.isEmpty
          ? Center(child: NoResultsWithTerm(term: widget.searchTerm))
          : ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                return EmojiItem(
                  onEmojiPress: widget.onEmojiPress,
                  name: data[index],
                );
              },
            ),
    );
  }
}
