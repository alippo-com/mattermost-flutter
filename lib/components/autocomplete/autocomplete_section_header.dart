import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart'; // For ActivityIndicator equivalent
import 'package:mattermost_flutter/components/formatted_text.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/typography.dart';

class AutocompleteSectionHeader extends StatelessWidget {
  final String defaultMessage;
  final String id;
  final bool loading;

  const AutocompleteSectionHeader({
    Key? key,
    required this.defaultMessage,
    required this.id,
    required this.loading,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final insets = MediaQuery.of(context).padding;
    final theme = useTheme(context);
    final style = getStyleFromTheme(theme);

    return Container(
      color: theme.centerChannelBg,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            Expanded(
              child: FormattedText(
                id: id,
                defaultMessage: defaultMessage,
                style: style['sectionText'],
              ),
            ),
            if (loading)
              SpinKitRing(
                color: changeOpacity(theme.centerChannelColor, 0.56),
                size: 24.0,
                lineWidth: 2.0,
              ),
          ],
        ),
      ),
    );
  }

  Map<String, TextStyle> getStyleFromTheme(ThemeData theme) {
    return {
      'sectionText': typography(
        'Body', 
        75, 
        'SemiBold',
      ).copyWith(
        textTransform: TextTransform.uppercase,
        color: changeOpacity(theme.centerChannelColor, 0.56),
        paddingTop: 16,
        paddingBottom: 8,
      ),
      'sectionWrapper': TextStyle(
        backgroundColor: theme.centerChannelBg,
      ),
      'loading': EdgeInsets.only(top: 16),
    };
  }
}
