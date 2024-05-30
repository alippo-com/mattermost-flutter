
import 'package:flutter/material.dart';
import 'package:mattermost_flutter/components/formatted_text.dart';
import 'package:mattermost_flutter/components/no_results_with_term.dart';
import 'package:mattermost_flutter/components/post_list/date_separator.dart';
import 'package:mattermost_flutter/components/post_with_channel_info.dart';
import 'package:mattermost_flutter/constants.dart';
import 'package:mattermost_flutter/utils/markdown.dart';
import 'package:mattermost_flutter/utils/post_list.dart';
import 'package:mattermost_flutter/utils/search.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/typography.dart';

class PostResults extends StatelessWidget {
  final bool appsEnabled;
  final List<String> customEmojiNames;
  final String currentTimezone;
  final List<PostModel> posts;
  final Map<String, List<SearchPattern>>? matches;
  final EdgeInsets paddingTop;
  final String searchValue;

  PostResults({
    required this.appsEnabled,
    required this.customEmojiNames,
    required this.currentTimezone,
    required this.posts,
    required this.matches,
    required this.paddingTop,
    required this.searchValue,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final styles = _getStyles(theme);
    final orderedPosts = selectOrderedPosts(posts, 0, false, '', '', false, currentTimezone, false).reversed.toList();
    final containerStyle = [paddingTop, BoxDecoration(flexGrow: 1)];

    Widget renderItem(BuildContext context, int index) {
      final item = orderedPosts[index];
      switch (item.type) {
        case 'date':
          return DateSeparator(
            key: ValueKey(item.value),
            date: getDateForDateLine(item.value),
            timezone: currentTimezone,
          );
        case 'post': {
          final key = item.value.currentPost.id;
          final hasPhrases = RegExp(r'"([^"]*)"').hasMatch(searchValue ?? '');
          List<SearchPattern>? searchPatterns;
          if (matches != null && !hasPhrases) {
            searchPatterns = matches[key]?.map(convertSearchTermToRegex).toList();
          } else {
            searchPatterns = parseSearchTerms(searchValue)
                ?.map(convertSearchTermToRegex)
                .toList()
                ..sort((a, b) => b.term.length.compareTo(a.term.length));
          }

          return PostWithChannelInfo(
            key: ValueKey(key),
            appsEnabled: appsEnabled,
            customEmojiNames: customEmojiNames,
            location: Screens.SEARCH,
            post: item.value.currentPost,
            searchPatterns: searchPatterns,
            testID: 'search_results.post_list',
          );
        }
        default:
          return Container();
      }
    }

    final noResults = NoResultsWithTerm(
      term: searchValue,
      type: TabTypes.MESSAGES,
    );

    return ListView.builder(
      padding: containerStyle,
      itemCount: orderedPosts.length,
      itemBuilder: renderItem,
      physics: BouncingScrollPhysics(),
    );
  }

  BoxDecoration _getStyles(ThemeData theme) {
    return BoxDecoration(
      resultsNumber: TextStyle(
        ...typography('Heading', 300),
        padding: EdgeInsets.all(20),
        color: theme.centerChannelColor,
      ),
    );
  }
}
