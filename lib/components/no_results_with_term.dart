import 'package:flutter/material.dart';
import 'package:mattermost_flutter/types/theme.dart';
import 'package:mattermost_flutter/components/formatted_text.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/typography.dart';
import 'package:mattermost_flutter/utils/search.dart';
import 'package:mattermost_flutter/i18n.dart';
import 'search_files_illustration.dart';
import 'search_illustration.dart';

class NoResultsWithTerm extends StatefulWidget {
  final String term;
  final TabType? type;

  NoResultsWithTerm({required this.term, this.type});

  @override
  _NoResultsWithTermState createState() => _NoResultsWithTermState();
}

class _NoResultsWithTermState extends State<NoResultsWithTerm> {
  late String titleId;
  late String defaultMessage;

  @override
  void initState() {
    super.initState();
    titleId = t('mobile.no_results_with_term');
    defaultMessage = 'No results for “${widget.term}”';
    if (widget.type == TabTypes.FILES) {
      titleId = t('mobile.no_results_with_term.files');
      defaultMessage = 'No files matching “${widget.term}”';
    } else {
      titleId = t('mobile.no_results_with_term.messages');
      defaultMessage = 'No matches found for “${widget.term}”';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = useTheme(context);
    final style = getStyleFromTheme(theme);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 32),
      height: double.infinity,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          widget.type == TabTypes.FILES
              ? SearchFilesIllustration()
              : SearchIllustration(),
          FormattedText(
            id: titleId,
            defaultMessage: defaultMessage,
            style: style['result'],
            values: {'term': widget.term},
          ),
          FormattedText(
            id: 'mobile.no_results.spelling',
            defaultMessage: 'Check the spelling or try another search.',
            style: style['spelling'],
          ),
        ],
      ),
    );
  }
}

Map<String, TextStyle> getStyleFromTheme(Theme theme) {
  return {
    'container': TextStyle(
      height: double.infinity,
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: 32),
    ),
    'result': typography('Heading', 400, 'SemiBold').merge(TextStyle(
      color: theme.centerChannelColor,
      textAlign: TextAlign.center,
    )),
    'spelling': typography('Body', 200).merge(TextStyle(
      color: changeOpacity(theme.centerChannelColor, 0.72),
      marginTop: 8,
    )),
  };
}
