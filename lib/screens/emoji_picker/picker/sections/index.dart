import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mattermost_flutter/components/touchable_emoji.dart';
import 'package:mattermost_flutter/constants/emoji.dart';
import 'package:mattermost_flutter/context/server.dart';
import 'package:mattermost_flutter/utils/emoji.dart';
import 'package:mattermost_flutter/components/emoji_category_bar.dart';
import 'package:mattermost_flutter/components/section_footer.dart';
import 'package:mattermost_flutter/components/section_header.dart';

class EmojiSections extends StatefulWidget {
  final List<CustomEmojiModel> customEmojis;
  final bool customEmojisEnabled;
  final Function(String) onEmojiPress;
  final List<String> recentEmojis;

  EmojiSections({
    required this.customEmojis,
    required this.customEmojisEnabled,
    required this.onEmojiPress,
    required this.recentEmojis,
  });

  @override
  _EmojiSectionsState createState() => _EmojiSectionsState();
}

class _EmojiSectionsState extends State<EmojiSections> {
  late final serverUrl = Provider.of<ServerUrl>(context, listen: false);
  late final isTablet = Provider.of<DeviceType>(context).isTablet;
  late final emojiCategoryBar = Provider.of<EmojiCategoryBar>(context, listen: false);

  int customEmojiPage = 0;
  bool fetchingCustomEmojis = false;
  bool loadedAllCustomEmojis = false;
  double offset = 0;
  bool manualScroll = false;

  late final sections = useMemo(() {
    final emojisPerRow = isTablet ? EMOJIS_PER_ROW_TABLET : EMOJIS_PER_ROW;

    return CategoryNames.map((category) {
      final emojiIndices = EmojiIndicesByCategory['default']![category];

      List<List<EmojiAlias>> data;
      switch (category) {
        case 'custom':
          final builtInCustom = emojiIndices.map((e) => fillEmoji('custom', e)).toList();
          final custom = widget.customEmojisEnabled
              ? widget.customEmojis.map((ce) => EmojiAlias(name: ce.name, shortName: '', aliases: [])).toList()
              : [];
          data = chunk(builtInCustom + custom, emojisPerRow);
          break;
        case 'recent':
          data = chunk(widget.recentEmojis.map((emoji) => EmojiAlias(name: emoji, shortName: '', aliases: [])).toList(), EMOJIS_PER_ROW);
          break;
        default:
          data = chunk(emojiIndices.map((e) => fillEmoji(category, e)).toList(), emojisPerRow);
          break;
      }

      for (var d in data) {
        if (d.length < emojisPerRow) {
          d.addAll(List.generate(emojisPerRow - d.length, (_) => emptyEmoji));
        }
      }

      return EmojiSection(
        key: category,
        data: data,
        icon: ICONS[category]!,
      );
    }).where((s) => s.data.isNotEmpty).toList();
  }, [widget.customEmojis, widget.customEmojisEnabled, isTablet]);

  @override
  void initState() {
    super.initState();
    setEmojiCategoryBarIcons(sections.map((s) => EmojiCategoryBarIcon(key: s.key, icon: s.icon)).toList());
  }

  Future<void> onLoadMoreCustomEmojis() async {
    if (!widget.customEmojisEnabled || fetchingCustomEmojis || loadedAllCustomEmojis) return;
    setState(() => fetchingCustomEmojis = true);
    final result = await fetchCustomEmojis(serverUrl, customEmojiPage, EMOJIS_PER_PAGE);
    if (result.data?.isNotEmpty ?? false) {
      setState(() => customEmojiPage += 1);
    } else if (result.data?.length ?? 0 < EMOJIS_PER_PAGE) {
      setState(() => loadedAllCustomEmojis = true);
    }
    setState(() => fetchingCustomEmojis = false);
  }

  void onScroll(ScrollNotification e) {
    final direction = e.metrics.pixels > offset ? 'up' : 'down';
    offset = e.metrics.pixels;

    if (manualScroll) return;

    final nextIndex = e.metrics.pixels >= emojiSectionsByOffset[categoryIndex + 1] - SECTION_HEADER_HEIGHT ? categoryIndex + 1 : categoryIndex;
    final prevIndex = e.metrics.pixels <= emojiSectionsByOffset[categoryIndex] - SECTION_HEADER_HEIGHT ? categoryIndex - 1 : categoryIndex;
    if (nextIndex > categoryIndex && direction == 'up') {
      setState(() => categoryIndex = nextIndex);
      setEmojiCategoryBarSection(nextIndex);
    } else if (prevIndex < categoryIndex && direction == 'down') {
      setState(() => categoryIndex = prevIndex);
      setEmojiCategoryBarSection(prevIndex);
    }
  }

  void scrollToIndex(int index) {
    setState(() => manualScroll = true);
    listController.scrollToIndex(index, duration: Duration(milliseconds: 350));
    setEmojiCategoryBarSection(index);
    Future.delayed(Duration(milliseconds: 350), () => setState(() => manualScroll = false));
  }

  Widget renderSectionHeader(BuildContext context, EmojiSection section) {
    return SectionHeader(section: section);
  }

  Widget renderFooter() {
    return fetchingCustomEmojis ? SectionFooter() : SizedBox.shrink();
  }

  Widget renderItem(BuildContext context, EmojiAlias item) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: item.map((emoji) {
        if (emoji.name.isEmpty && emoji.shortName.isEmpty) {
          return SizedBox(
            key: 'empty-${emoji.hashCode}',
            height: EMOJI_SIZE,
            width: EMOJI_SIZE,
          );
        }
        return TouchableEmoji(
          key: emoji.name,
          name: emoji.name,
          onEmojiPress: widget.onEmojiPress,
          category: emoji.category,
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: NotificationListener<ScrollNotification>(
            onNotification: (e) {
              onScroll(e);
              return true;
            },
            child: ListView.builder(
              controller: listController,
              itemBuilder: (context, index) {
                final item = sections[index];
                return renderItem(context, item);
              },
              itemCount: sections.length,
            ),
          ),
        ),
        if (isTablet) EmojiCategoryBar(),
      ],
    );
  }
}
