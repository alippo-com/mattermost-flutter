import 'package:flutter/material.dart';
import 'package:mattermost_flutter/actions/remote/preference.dart';
import 'package:mattermost_flutter/components/formatted_text.dart';
import 'package:mattermost_flutter/components/touchable_emoji.dart';
import 'package:mattermost_flutter/context/server.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/hooks/device.dart';
import 'package:mattermost_flutter/utils/emoji.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/typography.dart';

typedef OnSelectSkin = void Function();

class SkinSelector extends StatelessWidget {
  final OnSelectSkin onSelectSkin;
  final String selected;
  final Map<String, String> skins;

  const SkinSelector({
    Key? key,
    required this.onSelectSkin,
    required this.selected,
    required this.skins,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isTablet = useIsTablet();
    final theme = useTheme();
    final serverUrl = useServerUrl();
    final styles = getStyleSheet(theme);

    void handleSelectSkin(String emoji) async {
      final skin = emoji.split('hand_')[1] ?? 'default';
      final code = skinCodes.entries.firstWhere((entry) => entry.value == skin, orElse: () => const MapEntry('default', 'default')).key;
      await savePreferredSkinTone(serverUrl, code);
      onSelectSkin();
    }

    return Column(
      children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: 16),
          constraints: BoxConstraints(maxWidth: 57),
          child: FormattedText(
            id: 'default_skin_tone',
            defaultMessage: 'Default Skin Tone',
            style: styles['text'],
          ),
        ),
        Container(
          margin: isTablet ? EdgeInsets.only(right: 10) : null,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: skins.entries.map((entry) {
              final key = entry.key;
              final name = entry.value;
              return Container(
                width: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected == key ? changeOpacity(theme.buttonBg, 0.08) : null,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: TouchableEmoji(
                  name: name,
                  size: 28,
                  onEmojiPress: handleSelectSkin,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  getStyleSheet(Theme theme) {
    return {
      'text': TextStyle(
        color: theme.centerChannelColor,
        ...typography('Body', 75, 'SemiBold'),
      ),
    };
  }
}
