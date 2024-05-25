
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:mattermost_flutter/components/actions.dart';
import 'package:mattermost_flutter/components/avatar.dart';
import 'package:mattermost_flutter/components/copy_public_link.dart';
import 'package:mattermost_flutter/components/details.dart';
import 'package:mattermost_flutter/components/download_with_action.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/user.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

class Footer extends HookWidget {
  final UserModel? author;
  final bool canDownloadFiles;
  final String channelName;
  final String currentUserId;
  final bool enablePostIconOverride;
  final bool enablePostUsernameOverride;
  final bool enablePublicLink;
  final bool hideActions;
  final bool isDirectChannel;
  final GalleryItemType item;
  final PostModel? post;
  final TextStyle? style;
  final String teammateNameDisplay;
  final bool hasCaptions;
  final bool captionEnabled;
  final VoidCallback onCaptionsPress;

  Footer({
    this.author,
    required this.canDownloadFiles,
    required this.channelName,
    required this.currentUserId,
    required this.enablePostIconOverride,
    required this.enablePostUsernameOverride,
    required this.enablePublicLink,
    required this.hideActions,
    required this.isDirectChannel,
    required this.item,
    this.post,
    this.style,
    required this.teammateNameDisplay,
    required this.hasCaptions,
    required this.captionEnabled,
    required this.onCaptionsPress,
  });

  @override
  Widget build(BuildContext context) {
    final action = useState<GalleryAction>('none');
    final bottom = MediaQuery.of(context).padding.bottom;
    final bottomStyle = useMemo(() => BoxDecoration(height: bottom, color: Colors.black), [bottom]);

    String? overrideIconUrl;
    if (enablePostIconOverride && post?.props?.useUserIcon != 'true' && post?.props?.overrideIconUrl != null) {
      overrideIconUrl = post!.props!.overrideIconUrl!;
    }

    String userDisplayName;
    if (item.type == 'avatar') {
      userDisplayName = item.name;
    } else if (enablePostUsernameOverride && post?.props?.overrideUsername != null) {
      userDisplayName = post!.props!.overrideUsername!;
    } else {
      userDisplayName = displayUsername(author, null, teammateNameDisplay);
    }

    useEffect(() {
      final listener = DeviceEventEmitter.on<GalleryAction>(Events.GALLERY_ACTIONS, (value) {
        action.value = value;
      });

      return () => listener.dispose();
    }, []);

    return SafeArea(
      child: Column(
        children: [
          if (['downloading', 'sharing'].contains(action.value))
            DownloadWithAction(action: action.value, item: item, setAction: action.value),
          if (action.value == 'copying')
            CopyPublicLink(item: item, setAction: action.value),
          Container(
            alignment: Alignment.center,
            color: Colors.black,
            height: GALLERY_FOOTER_HEIGHT,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (item.type != 'avatar')
                  Avatar(authorId: author?.id, overrideIconUrl: overrideIconUrl),
                Details(
                  channelName: item.type == 'avatar' ? '' : channelName,
                  isDirectChannel: isDirectChannel,
                  ownPost: author?.id == currentUserId,
                  userDisplayName: userDisplayName,
                ),
                if (!hideActions && item.id != null && !item.id!.startsWith('uid'))
                  Actions(
                    disabled: action.value != 'none',
                    canDownloadFiles: canDownloadFiles,
                    enablePublicLinks: enablePublicLink && item.type != 'avatar',
                    fileId: item.id!,
                    onCopyPublicLink: () => action.value = 'copying',
                    onDownload: () async => action.value = 'downloading',
                    onShare: () => action.value = 'sharing',
                    hasCaptions: hasCaptions,
                    captionEnabled: captionEnabled,
                    onCaptionsPress: onCaptionsPress,
                  ),
              ],
            ),
          ),
          Container(style: bottomStyle),
        ],
      ),
    );
  }
}
