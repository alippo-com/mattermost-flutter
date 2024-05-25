// Converted code for post_options.tsx to post_options.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mattermost_flutter/components/common_post_options/copy_permalink_option.dart';
import 'package:mattermost_flutter/components/common_post_options/follow_thread_option.dart';
import 'package:mattermost_flutter/components/common_post_options/reply_option.dart';
import 'package:mattermost_flutter/components/common_post_options/save_option.dart';
import 'package:mattermost_flutter/screens/bottom_sheet.dart';
import 'package:mattermost_flutter/constants.dart';
import 'package:mattermost_flutter/constants/reaction_picker.dart';
import 'package:mattermost_flutter/hooks/device.dart';
import 'package:mattermost_flutter/hooks/navigation_button_pressed.dart';
import 'package:mattermost_flutter/screens/navigation.dart';
import 'package:mattermost_flutter/utils/helpers.dart';
import 'package:mattermost_flutter/utils/post.dart';
import 'package:mattermost_flutter/types/database/models/servers/post.dart';
import 'package:mattermost_flutter/types/database/models/servers/thread.dart';
import 'package:mattermost_flutter/types/screens/navigation.dart';
import 'package:provider/provider.dart';
import 'package:mattermost_flutter/components/option_item.dart';
import 'package:mattermost_flutter/screens/post_options/options/app_bindings_post_option.dart';
import 'package:mattermost_flutter/screens/post_options/options/copy_text_option.dart';
import 'package:mattermost_flutter/screens/post_options/options/delete_post_option.dart';
import 'package:mattermost_flutter/screens/post_options/options/edit_option.dart';
import 'package:mattermost_flutter/screens/post_options/options/mark_unread_option.dart';
import 'package:mattermost_flutter/screens/post_options/options/pin_channel_option.dart';
import 'package:mattermost_flutter/screens/post_options/reaction_bar.dart';
import 'package:react_native_emm/use_managed_config.dart';
import 'package:react_native_safe_area_context/safe_area_context.dart';

class PostOptions extends StatelessWidget {
  final bool canAddReaction;
  final bool canDelete;
  final bool canEdit;
  final bool canMarkAsUnread;
  final bool canPin;
  final bool canReply;
  final PostModel combinedPost;
  final bool isSaved;
  final AvailableScreens sourceScreen;
  final PostModel post;
  final ThreadModel thread;
  final AvailableScreens componentId;
  final List<AppBinding> bindings;
  final String serverUrl;

  PostOptions({
    required this.canAddReaction,
    required this.canDelete,
    required this.canEdit,
    required this.canMarkAsUnread,
    required this.canPin,
    required this.canReply,
    required this.combinedPost,
    required this.isSaved,
    required this.sourceScreen,
    required this.post,
    required this.thread,
    required this.componentId,
    required this.bindings,
    required this.serverUrl,
  });

  @override
  Widget build(BuildContext context) {
    final managedConfig = useManagedConfig<ManagedConfig>();
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final isTablet = useIsTablet(context);
    final Scroll = isTablet ? ScrollView : BottomSheetScrollView;

    void close() {
      dismissBottomSheet(Screens.POST_OPTIONS);
    }

    useNavButtonPressed(POST_OPTIONS_BUTTON, componentId, close);

    final isSystemPost = isSystemMessage(post);

    final canCopyPermalink =
        !isSystemPost && managedConfig.copyAndPasteProtection != 'true';
    final canCopyText = canCopyPermalink && post.message != null;

    final shouldRenderFollow =
        !(sourceScreen != Screens.CHANNEL || thread == null);
    final shouldShowBindings = bindings.isNotEmpty && !isSystemPost;

    final snapPoints = useMemo(() {
      final items = [1];
      final optionsCount = [
        canCopyPermalink,
        canCopyText,
        canDelete,
        canEdit,
        canMarkAsUnread,
        canPin,
        canReply,
        !isSystemPost,
        shouldRenderFollow,
      ].where((v) => v).length +
          (shouldShowBindings ? 0.5 : 0);

      items.add(bottomSheetSnapPoint(optionsCount, ITEM_HEIGHT, bottom) +
          (canAddReaction ? REACTION_PICKER_HEIGHT + REACTION_PICKER_MARGIN : 0));

      if (shouldShowBindings) {
        items.add('80%');
      }

      return items;
    }, [
      canAddReaction,
      canCopyPermalink,
      canCopyText,
      canDelete,
      canEdit,
      shouldRenderFollow,
      shouldShowBindings,
      canMarkAsUnread,
      canPin,
      canReply,
      isSystemPost,
      bottom,
    ]);

    Widget renderContent() {
      return Scroll(
        physics: BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (canAddReaction)
              ReactionBar(
                bottomSheetId: Screens.POST_OPTIONS,
                postId: post.id,
              ),
            if (canReply)
              ReplyOption(
                bottomSheetId: Screens.POST_OPTIONS,
                post: post,
              ),
            if (shouldRenderFollow)
              FollowThreadOption(
                bottomSheetId: Screens.POST_OPTIONS,
                thread: thread,
              ),
            if (canMarkAsUnread && !isSystemPost)
              MarkAsUnreadOption(
                bottomSheetId: Screens.POST_OPTIONS,
                post: post,
                sourceScreen: sourceScreen,
              ),
            if (canCopyPermalink)
              CopyPermalinkOption(
                bottomSheetId: Screens.POST_OPTIONS,
                post: post,
                sourceScreen: sourceScreen,
              ),
            if (!isSystemPost)
              SaveOption(
                bottomSheetId: Screens.POST_OPTIONS,
                isSaved: isSaved,
                postId: post.id,
              ),
            if (canCopyText && post.message != null)
              CopyTextOption(
                bottomSheetId: Screens.POST_OPTIONS,
                postMessage: post.message!,
                sourceScreen: sourceScreen,
              ),
            if (canPin)
              PinChannelOption(
                bottomSheetId: Screens.POST_OPTIONS,
                isPostPinned: post.isPinned,
                postId: post.id,
              ),
            if (canEdit)
              EditOption(
                bottomSheetId: Screens.POST_OPTIONS,
                post: post,
                canDelete: canDelete,
              ),
            if (canDelete)
              DeletePostOption(
                bottomSheetId: Screens.POST_OPTIONS,
                combinedPost: combinedPost,
                post: post,
              ),
            if (shouldShowBindings)
              AppBindingsPostOptions(
                bottomSheetId: Screens.POST_OPTIONS,
                post: post,
                serverUrl: serverUrl,
                bindings: bindings,
              ),
          ],
        ),
      );
    }

    return BottomSheet(
      renderContent: renderContent,
      closeButtonId: POST_OPTIONS_BUTTON,
      componentId: Screens.POST_OPTIONS,
      initialSnapIndex: 1,
      snapPoints: snapPoints,
      testID: 'post_options',
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: Scaffold(
      body: PostOptions(
        canAddReaction: true,
        canDelete: true,
        canEdit: true,
        canMarkAsUnread: true,
        canPin: true,
        canReply: true,
        combinedPost: PostModel(),
        isSaved: true,
        sourceScreen: AvailableScreens.CHANNEL,
        post: PostModel(),
        thread: ThreadModel(),
        componentId: AvailableScreens.POST_OPTIONS,
        bindings: [],
        serverUrl: '',
      ),
    ),
  ));
}
