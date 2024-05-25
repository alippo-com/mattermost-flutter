import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:mattermost_flutter/actions/remote/preference.dart';
import 'package:mattermost_flutter/components/compass_icon.dart';
import 'package:mattermost_flutter/components/formatted_text.dart';
import 'package:mattermost_flutter/constants/screens.dart';
import 'package:mattermost_flutter/context/server.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/hooks/device.dart';
import 'package:mattermost_flutter/hooks/fetching_thread.dart';
import 'package:mattermost_flutter/screens/navigation.dart';
import 'package:mattermost_flutter/utils/tap.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/typography.dart';

import 'package:mattermost_flutter/types/database/models/servers/post.dart';

class ThreadOverview extends StatelessWidget {
  final bool isSaved;
  final int repliesCount;
  final String rootId;
  final PostModel? rootPost;
  final String testID;
  final TextStyle? style;

  const ThreadOverview({
    Key? key,
    required this.isSaved,
    required this.repliesCount,
    required this.rootId,
    this.rootPost,
    required this.testID,
    this.style,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = useTheme();
    final styles = getStyleSheet(theme);

    final intl = useIntl();
    final isTablet = useIsTablet();
    final serverUrl = useServerUrl();
    final isFetchingThread = useFetchingThreadState(rootId);

    void onHandleSavePress() {
      preventDoubleTap(() {
        if (rootPost?.id != null) {
          final remoteAction = isSaved ? deleteSavedPost : savePostPreference;
          remoteAction(serverUrl, rootPost!.id);
        }
      });
    }

    void showPostOptions() {
      preventDoubleTap(() {
        Keyboard.dismiss();
        if (rootPost?.id != null) {
          final passProps = {
            'sourceScreen': Screens.THREAD,
            'post': rootPost,
            'showAddReaction': true,
          };
          final title = isTablet ? intl.message('post.options.title', 'Options') : '';

          if (isTablet) {
            showModal(Screens.POST_OPTIONS, title, passProps, bottomSheetModalOptions(theme, 'close-post-options'));
          } else {
            showModalOverCurrentContext(Screens.POST_OPTIONS, passProps, bottomSheetModalOptions(theme));
          }
        }
      });
    }

    final containerStyle = <TextStyle>[styles['container']!];
    if (repliesCount == 0) {
      containerStyle.add(const TextStyle(borderBottomWidth: 0));
    }
    if (style != null) {
      containerStyle.add(style!);
    }

    final saveButtonTestId = isSaved ? '$testID.unsave.button' : '$testID.save.button';

    Widget? repliesCountElement;
    if (repliesCount > 0) {
      repliesCountElement = FormattedText(
        style: styles['repliesCount'],
        id: 'thread.repliesCount',
        defaultMessage: '{repliesCount, number} {repliesCount, plural, one {reply} other {replies}}',
        testID: '$testID.replies_count',
        values: {'repliesCount': repliesCount},
      );
    } else if (isFetchingThread) {
      repliesCountElement = FormattedText(
        style: styles['repliesCount'],
        id: 'thread.loadingReplies',
        defaultMessage: 'Loading replies...',
        testID: '$testID.loading_replies',
      );
    } else {
      repliesCountElement = FormattedText(
        style: styles['repliesCount'],
        id: 'thread.noReplies',
        defaultMessage: 'No replies yet',
        testID: '$testID.no_replies',
      );
    }

    return Container(
      style: containerStyle,
      child: Row(
        children: [
          Expanded(
            child: Container(
              style: styles['repliesCountContainer'],
              child: repliesCountElement,
            ),
          ),
          Row(
            children: [
              GestureDetector(
                onTap: onHandleSavePress,
                child: Container(
                  margin: const EdgeInsets.only(left: 16),
                  child: CompassIcon(
                    size: 24,
                    name: isSaved ? 'bookmark' : 'bookmark-outline',
                    color: isSaved ? theme.linkColor : changeOpacity(theme.centerChannelColor, 0.64),
                  ),
                ),
              ),
              GestureDetector(
                onTap: showPostOptions,
                child: Container(
                  margin: const EdgeInsets.only(left: 16),
                  child: CompassIcon(
                    size: 24,
                    name: Platform.isAndroid ? 'dots-vertical' : 'dots-horizontal',
                    color: changeOpacity(theme.centerChannelColor, 0.64),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Map<String, TextStyle> getStyleSheet(Theme theme) {
    return {
      'container': TextStyle(
        borderTopWidth: 1,
        borderBottomWidth: 1,
        borderColor: changeOpacity(theme.centerChannelColor, 0.1),
        flexDirection: 'row',
        marginVertical: 12,
        paddingHorizontal: 16,
        paddingVertical: 10,
      ),
      'repliesCountContainer': TextStyle(
        flex: 1,
      ),
      'repliesCount': TextStyle(
        color: changeOpacity(theme.centerChannelColor, 0.64),
        marginHorizontal: 4,
        ...typography('Body', 200, 'Regular'),
      ),
      'optionsContainer': TextStyle(
        flexDirection: 'row',
      ),
      'optionContainer': TextStyle(
        marginLeft: 16,
      ),
    };
  }
}
