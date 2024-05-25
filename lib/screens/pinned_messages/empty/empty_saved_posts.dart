import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mattermost_flutter/components/formatted_text.dart'; // Placeholder for formatted text component
import 'package:mattermost_flutter/context/theme.dart'; // Placeholder for theme context
import 'package:mattermost_flutter/utils/theme.dart'; // Placeholder for theme utilities
import 'package:mattermost_flutter/utils/typography.dart'; // Placeholder for typography utilities

class EmptySavedPosts extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = useTheme(context);
    final styles = _getStyleSheet(theme);

    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: 40),
      constraints: BoxConstraints(maxWidth: 480),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset('assets/empty.svg'),
          FormattedText(
            defaultMessage: 'No pinned messages yet',
            id: 'pinned_messages.empty.title',
            style: styles.title,
            testID: 'pinned_messages.empty.title',
          ),
          SizedBox(height: 8), // Added SizedBox for spacing
          FormattedText(
            defaultMessage: 'To pin important messages, long-press on a message and choose Pin To Channel. Pinned messages will be visible to everyone in this channel.',
            id: 'pinned_messages.empty.paragraph',
            style: styles.paragraph,
            testID: 'pinned_messages.empty.paragraph',
          ),
        ],
      ),
    );
  }

  _getStyleSheet(ThemeData theme) {
    return _Styles(
      container: BoxDecoration(),
      title: TextStyle(
        color: theme.centerChannelColor,
        textAlign: TextAlign.center,
        // Assuming typography is a method to get TextStyle
        ...typography('Heading', 400, 'SemiBold'),
      ),
      paragraph: TextStyle(
        textAlign: TextAlign.center,
        color: changeOpacity(theme.centerChannelColor, 0.72),
        // Assuming typography is a method to get TextStyle
        ...typography('Body', 200),
      ),
    );
  }
}

class _Styles {
  final BoxDecoration container;
  final TextStyle title;
  final TextStyle paragraph;

  _Styles({required this.container, required this.title, required this.paragraph});
}
