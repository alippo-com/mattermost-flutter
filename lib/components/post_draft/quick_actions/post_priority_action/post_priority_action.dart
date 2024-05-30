
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:mattermost_flutter/components/compass_icon.dart';
import 'package:mattermost_flutter/components/touchable_with_feedback.dart';
import 'package:mattermost_flutter/constants/post_draft.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/utils/theme.dart';

class PostPriorityAction extends HookWidget {
  final String? testID;
  final PostPriority postPriority;
  final Function(PostPriority) updatePostPriority;

  PostPriorityAction({
    this.testID,
    required this.postPriority,
    required this.updatePostPriority,
  });

  @override
  Widget build(BuildContext context) {
    final intl = useIntl(context);
    final isTablet = useIsTablet(context);
    final theme = useTheme(context);

    final onPress = useCallback(() {
      FocusScope.of(context).unfocus();

      final title = isTablet
          ? intl.formatMessage(id: 'post_priority.picker.title', defaultMessage: 'Message priority')
          : '';

      openAsBottomSheet(
        context,
        closeButtonId: POST_PRIORITY_PICKER_BUTTON,
        screen: Screens.POST_PRIORITY_PICKER,
        theme: theme,
        title: title,
        props: {
          'postPriority': postPriority,
          'updatePostPriority': updatePostPriority,
          'closeButtonId': POST_PRIORITY_PICKER_BUTTON,
        },
      );
    }, [intl, postPriority, updatePostPriority, theme]);

    final iconName = 'alert-circle-outline';
    final iconColor = changeOpacity(theme.centerChannelColor, 0.64);

    return TouchableWithFeedback(
      testID: testID,
      onPress: onPress,
      style: iconStyle,
      type: 'opacity',
      child: CompassIcon(
        name: iconName,
        color: iconColor,
        size: ICON_SIZE,
      ),
    );
  }

  final iconStyle = BoxDecoration(
    alignItems: 'center',
    justifyContent: 'center',
    padding: EdgeInsets.all(10),
  );
}

const POST_PRIORITY_PICKER_BUTTON = 'close-post-priority-picker';
