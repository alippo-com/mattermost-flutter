// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:emoji_regex/emoji_regex.dart';
import 'package:mattermost_flutter/types/database/models/servers/custom_emoji.dart';
import 'package:mattermost_flutter/utils/emoji.dart';

final UNICODE_REGEX = RegExp(r'\p{Emoji}', unicode: true);

final RE_NAMED_EMOJI = RegExp(r'(:([a-zA-Z0-9_+-]+):)');

final RE_UNICODE_EMOJI = emojiRegex();

final RE_EMOTICON = {
  'slightly_smiling_face': RegExp(r'(^|\s)(:-?\))(?=$|\s)'), // :)
  'wink': RegExp(r'(^|\s)(;-?\))(?=$|\s)'), // ;)
  'open_mouth': RegExp(r'(^|\s)(:o)(?=$|\s)', caseSensitive: false), // :o
  'scream': RegExp(r'(^|\s)(:-o)(?=$|\s)', caseSensitive: false), // :-o
  'smirk': RegExp(r'(^|\s)(:-?])(?=$|\s)'), // :]
  'smile': RegExp(r'(^|\s)(:-?d)(?=$|\s)', caseSensitive: false), // :D
  'stuck_out_tongue_closed_eyes': RegExp(r'(^|\s)(x-d)(?=$|\s)', caseSensitive: false), // x-d
  'stuck_out_tongue': RegExp(r'(^|\s)(:-?p)(?=$|\s)', caseSensitive: false), // :p
  'rage': RegExp(r'(^|\s)(:-?[@])(?=$|\s)'), // :@
  'slightly_frowning_face': RegExp(r'(^|\s)(:-?\()(?=$|\s)'), // :(
  'cry': RegExp(r'(^|\s)(:[`'’]-?\(|:&#x27;\(|:&#39;\()(?=$|\s)'), // :`(
  'confused': RegExp(r'(^|\s)(:-?\/)(?=$|\s)'), // :/
  'confounded': RegExp(r'(^|\s)(:-?s)(?=$|\s)', caseSensitive: false), // :s
  'neutral_face': RegExp(r'(^|\s)(:-?\|)(?=$|\s)'), // :|
  'flushed': RegExp(r'(^|\s)(:-?\$)(?=$|\s)'), // :$
  'mask': RegExp(r'(^|\s)(:-x)(?=$|\s)', caseSensitive: false), // :-x
  'heart': RegExp(r'(^|\s)(<3|&lt;3)(?=$|\s)'), // <3
  'broken_heart': RegExp(r'(^|\s)(<\/3|&lt;&#x2F;3)(?=$|\s)'), // </3
};

// TODO This only check for named emojis: https://mattermost.atlassian.net/browse/MM-41505
final RE_REACTION = RegExp(r'^(\+|-):([^:\s]+):\s*$');

const MAX_JUMBO_EMOJIS = 8;

bool isEmoticon(String text) {
  for (var emoticon in RE_EMOTICON.keys) {
    final reEmoticon = RE_EMOTICON[emoticon]!;
    final matchEmoticon = reEmoticon.firstMatch(text);
    if (matchEmoticon != null && matchEmoticon.group(0) == text) {
      return true;
    }
  }
  return false;
}

bool isUnicodeEmoji(String text) {
  return UNICODE_REGEX.hasMatch(text);
}

String? getEmoticonName(String value) {
  return RE_EMOTICON.keys.firstWhere((key) => RE_EMOTICON[key]!.hasMatch(value), orElse: () => null);
}

List<String> matchEmoticons(String text) {
  var emojis = RE_NAMED_EMOJI.allMatches(text).map((m) => m.group(0)!).toList();

  for (var name in RE_EMOTICON.keys) {
    final pattern = RE_EMOTICON[name]!;
    final matches = pattern.allMatches(text).map((m) => m.group(0)!);
    emojis.addAll(matches);
  }

  final matchUnicodeEmoji = RE_UNICODE_EMOJI.allMatches(text).map((m) => m.group(0)!);
  emojis.addAll(matchUnicodeEmoji);

  return emojis;
}

List<String> getValidEmojis(List<String> emojis, List<CustomEmojiModel> customEmojis) {
  final emojiNames = <String>{};
  final customEmojiNames = customEmojis.map((v) => v.name);

  for (var emoji in emojis) {
    final emojiName = getEmojiName(emoji, customEmojiNames);
    if (emojiName != null) {
      emojiNames.add(emojiName);
    }
  }

  return emojiNames.toList();
}

String? getEmojiName(String emoji, List<String> customEmojiNames) {
  if (doesMatchNamedEmoji(emoji)) {
    final emojiName = emoji.substring(1, emoji.length - 1);
    if (isValidNamedEmoji(emojiName, customEmojiNames)) {
      return emojiName;
    }
  }

  final matchUnicodeEmoji = RE_UNICODE_EMOJI.firstMatch(emoji);
  if (matchUnicodeEmoji != null) {
    final index = EmojiIndicesByUnicode[matchUnicodeEmoji.group(0)];
    if (index != null) {
      return fillEmoji('', index).name;
    }
    return null;
  }

  final emojiName = getEmoticonName(emoji);
  if (emojiName != null) {
    return emojiName;
  }

  return null;
}

Map<String, dynamic>? isReactionMatch(String value, List<CustomEmojiModel> customEmojis) {
  final customEmojiNames = customEmojis.map((v) => v.name);

  final match = RE_REACTION.firstMatch(value);
  if (match == null) {
    return null;
  }

  if (!isValidNamedEmoji(match.group(2)!, customEmojiNames)) {
    return null;
  }

  return {
    'add': match.group(1) == '+',
    'emoji': match.group(2),
  };
}

bool isValidNamedEmoji(String emojiName, List<String> customEmojiNames) {
  if (EmojiIndicesByAlias.containsKey(emojiName)) {
    return true;
  }

  if (customEmojiNames.contains(emojiName)) {
    return true;
  }

  return false;
}

bool hasJumboEmojiOnly(String message, List<String> customEmojis) {
  var emojiCount = 0;
  final chunks = message.trim().replaceAll('\n', ' ').split(' ').where((m) => m.isNotEmpty).toList();
  if (chunks.isEmpty) {
    return false;
  }

  final emojisSet = customEmojis.toSet();
  for (var chunk in chunks) {
    if (doesMatchNamedEmoji(chunk)) {
      final emojiName = chunk.substring(1, emoji.length - 1);
      if (EmojiIndicesByAlias.containsKey(emojiName)) {
        emojiCount++;
        continue;
      }

      if (emojisSet.contains(emojiName)) {
        emojiCount++;
        continue;
      }
    }

    final matchUnicodeEmoji = RE_UNICODE_EMOJI.allMatches(chunk).map((m) => m.group(0)!).toList();
    if (matchUnicodeEmoji.isNotEmpty && matchUnicodeEmoji.join('') == chunk) {
      emojiCount += matchUnicodeEmoji.length;
      continue;
    }

    if (isEmoticon(chunk)) {
      emojiCount++;
      continue;
    }

    return false;
  }

  return emojiCount > 0 && emojiCount <= MAX_JUMBO_EMOJIS;
}

bool doesMatchNamedEmoji(String emojiName) {
  final match = RE_NAMED_EMOJI.firstMatch(emojiName);
  return match != null && match.group(0) == emojiName;
}

String getEmojiFirstAlias(String emoji) {
  return getEmojiByName(emoji, [])?.shortNames?.first ?? emoji;
}

CustomEmojiModel? getEmojiByName(String emojiName, List<CustomEmojiModel> customEmojis) {
  if (EmojiIndicesByAlias.containsKey(emojiName)) {
    return Emojis[EmojiIndicesByAlias[emojiName]!];
  }

  return customEmojis.firstWhere((e) => e.name == emojiName, orElse: () => null);
}

List<String> mapCustomEmojiNames(List<CustomEmojiModel> customEmojis) {
  return customEmojis.map((c) => c.name).toList();
}

// Since there is no shared logic between the web and mobile app
// this is copied from the webapp as custom sorting logic for emojis

int defaultComparisonRule(String aName, String bName) {
  return aName.compareTo(bName);
}

int thumbsDownComparisonRule(String other) {
  return (other.startsWith('thumbsup') || other.startsWith('+1')) ? 1 : 0;
}

int thumbsUpComparisonRule(String other) {
  return (other.startsWith('thumbsdown') || other.startsWith('-1')) ? -1 : 0;
}

typedef Comparators = Map<String, int Function(String)>;

final customComparisonRules = <String, int Function(String)>{
  'thumbsdown': thumbsDownComparisonRule,
  '-1': thumbsDownComparisonRule,
  'thumbsup': thumbsUpComparisonRule,
  '+1': thumbsUpComparisonRule,
};

int doDefaultComparison(String aName, String bName) {
  final rule = aName.split('_')[0];
  if (customComparisonRules.containsKey(rule)) {
    return customComparisonRules[rule]!(bName) ?? defaultComparisonRule(aName, bName);
  }

  return defaultComparisonRule(aName, bName);
}

typedef EmojiType = {
  String shortName;
  String name;
};

int compareEmojis(dynamic emojiA, dynamic emojiB, String searchedName) {
  if (emojiA == null) {
    return 1;
  }

  if (emojiB == null) {
    return -1;
  }
  
  late String aName;
  if (emojiA is String) {
    aName = emojiA;
  } else {
    aName = emojiA.shortName ?? emojiA.name;
  }

  late String bName;
  if (emojiB is String) {
    bName = emojiB;
  } else {
    bName = emojiB.shortName ?? emojiB.name;
  }

  if (searchedName.isEmpty) {
    return doDefaultComparison(aName, bName);
  }

  // Have the emojis that start with the search appear first
  final aPrefix = aName.startsWith(searchedName);
  final bPrefix = bName.startsWith(searchedName);

  if (aPrefix && bPrefix) {
    return doDefaultComparison(aName, bName);
  } else if (aPrefix) {
    return -1;
  } else if (bPrefix) {
    return 1;
  }

  // Have the emojis that contain the search appear next
  final aIncludes = aName.contains(searchedName);
  final bIncludes = bName.contains(searchedName);

  if (aIncludes && bIncludes) {
    return doDefaultComparison(aName, bName);
  } else if (aIncludes) {
    return -1;
  } else if (bIncludes) {
    return 1;
  }

  return doDefaultComparison(aName, bName);
}

bool isCustomEmojiEnabled(dynamic config) {
  if (config is SystemModel) {
    return config.value?.EnableCustomEmoji == 'true';
  }

  return config.EnableCustomEmoji == 'true';
}

fillEmoji(String category, int index) {
  final emoji = Emojis[index];
  return {
    'name': emoji.shortName ?? emoji.name,
    'aliases': emoji.shortNames ?? [],
    'category': category,
  };
}

String? getSkin(dynamic emoji) {
  if (emoji['skin_variations'] != null) {
    return 'default';
  }
  if (emoji['skins'] != null) {
    return emoji['skins'] != null ? emoji['skins'][0] : null;
  }
  return null;
}

List<String> getEmojis(String skinTone, List<CustomEmojiModel> customEmojis) {
  final emoticons = <String>{};
  for (var entry in EmojiIndicesByAlias.entries) {
    final skin = getSkin(Emojis[entry.value]);
    if (skin == null || skin == skinTone) {
      emoticons.add(entry.key);
    }
  }

  for (var custom in customEmojis) {
    emoticons.add(custom.name);
  }

  return emoticons.toList();
}

List<String> searchEmojis(dynamic fuse, String searchTerm) {
  final searchTermLowerCase = searchTerm.toLowerCase();

  final sorter = (String a, String b) {
    return compareEmojis(a, b, searchTermLowerCase);
  };

  final fuzz = fuse.search(searchTermLowerCase);

  if (fuzz != null) {
    final results = fuzz.reduce<List<String>>((values, r) {
      final score = r?.score == null ? 1 : r.score;
      final v = r?.matches?.first.value;
      if (score < 0.2 && v != null) {
        values.add(v);
      }

      return values;
    }, []);

    return results.sort(sorter);
  }

  return [];
}
